import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInatialState());
  static AuthCubit get(context) => BlocProvider.of(context);

  final formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  bool termsAccepted = false;

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
    confirmPasswordController.clear();
  }

  void setTermsAccepted(bool accepted) {
    termsAccepted = accepted;
    emit(AuthTermsState(accepted: accepted));
  }

  Future<void> saveUserData(User user) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      print("FCM TOKEN => $fcmToken");

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": user.displayName ?? nameController.text.trim(),
        "email": user.email ?? emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "fcmToken": fcmToken ?? "",
        "platform": "android",
      }, SetOptions(merge: true));
    } catch (e) {
      print("SAVE USER ERROR => $e");
      rethrow;
    }
  }

  Future<void> register() async {
    if (!termsAccepted) {
      emit(AuthErrorState(error: 'Please agree to the Terms and Conditions'));
      return;
    }

    emit(AuthLoadingState());

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = credential.user;
      await user?.updateDisplayName(nameController.text);
      if (user == null) {
        emit(AuthErrorState(error: 'Failed to create user'));
        return;
      }

      await user.sendEmailVerification();
      emit(AuthVerifyEmailState());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthErrorState(error: 'Weak password'));
      } else if (e.code == 'email-already-in-use') {
        emit(AuthErrorState(error: 'Email already exists'));
      } else {
        emit(AuthErrorState(error: 'Something went wrong'));
      }
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        emit(AuthErrorState(error: 'No authenticated user'));
        return;
      }

      await currentUser.reload();

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        emit(AuthErrorState(error: 'No authenticated user'));
        return;
      }

      print("EMAIL VERIFIED => ${user.emailVerified}");

      if (user.emailVerified) {
        await saveUserData(user);

        emit(AuthSuccessState());
      } else {
        emit(AuthErrorState(error: "Please verify your email"));
      }
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  Future<void> resendVerificationEmail() async {
    emit(AuthLoadingState());

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AuthErrorState(error: 'No signed in user'));
        return;
      }

      await user.sendEmailVerification();
      emit(AuthVerifyEmailState());
    } on FirebaseAuthException catch (e) {
      emit(
        AuthErrorState(
          error: e.message ?? 'Failed to resend verification email',
        ),
      );
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(AuthLoadingState());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(AuthPasswordResetEmailSentState());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send reset email';
      if (e.code == 'user-not-found') errorMessage = 'Account not found';
      if (e.code == 'invalid-email') errorMessage = 'Invalid email address';

      emit(AuthErrorState(error: errorMessage));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  String _extractPasswordResetCode(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri != null && uri.queryParameters.containsKey('oobCode')) {
      return uri.queryParameters['oobCode']!.trim();
    }
    return input.trim();
  }

  Future<void> confirmPasswordReset({
    required String codeOrLink,
    required String newPassword,
  }) async {
    emit(AuthLoadingState());
    try {
      final actionCode = _extractPasswordResetCode(codeOrLink);

      await FirebaseAuth.instance.verifyPasswordResetCode(actionCode);

      await FirebaseAuth.instance.confirmPasswordReset(
        code: actionCode,
        newPassword: newPassword,
      );

      emit(AuthPasswordResetSuccessState());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to reset password';
      if (e.code == 'expired-action-code') {
        errorMessage = 'Reset code has expired';
      }
      if (e.code == 'invalid-action-code') {
        errorMessage = 'Invalid reset code or link';
      }
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak';
      }

      emit(AuthErrorState(error: errorMessage));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoadingState());

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        emit(AuthErrorState(error: "No account selected"));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user != null) {
        await saveUserData(user);
      }

      emit(AuthSuccessState());
    } on FirebaseAuthException catch (e) {
      emit(AuthErrorState(error: e.message ?? "Google Sign In Failed"));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoadingState());
    try {
      // 1. محاولة تسجيل الدخول بالبيانات

      var auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // 2. التشيك السحري: هل الإيميل متفعل في الفايربيز؟
      if (user != null && !user.emailVerified) {
        // ❌ لو مش متفعل، بنعمل تسجيل خروج فوراً ومبنخليهوش يدخل الأبليكيشن
        await auth.signOut();

        // ونبعت حالة إيرور تظهر في التوست للمستخدم
        emit(
          AuthErrorState(
            error: "Please verify your email address before logging in.",
          ),
        );
        return;
      }
      if (user != null) {
        await saveUserData(user);
      }
      //  لو متفعل تمام، ينقل على الشاشة الرئيسية بنجاح
      emit(AuthSuccessState());
    } on FirebaseAuthException catch (e) {
      emit(AuthErrorState(error: e.message ?? "An error occurred"));
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  deleteUserById() async {
    try {
      emit(AuthLoadingState());
      var currentuser = FirebaseAuth.instance.currentUser;
      await currentuser?.delete();
      emit(AuthSuccessState());
    } on Exception catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }
}
