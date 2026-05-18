import 'package:cloud_firestore/cloud_firestore.dart';
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

    if (user.emailVerified) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "uid": user.uid,
      });

      emit(AuthSuccessState());
    } else {
      emit(AuthErrorState(error: "Please verify your email"));
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

  // 1. إرسال إيميل إعادة التعيين
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

  // 2. دالة استخراج الكود السري (Private)
  String _extractPasswordResetCode(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri != null && uri.queryParameters.containsKey('oobCode')) {
      return uri.queryParameters['oobCode']!.trim();
    }
    return input.trim();
  }

  // 3. دالة تأكيد تغيير الباسورد النهائية
  Future<void> confirmPasswordReset({
    required String codeOrLink,
    required String newPassword,
  }) async {
    emit(AuthLoadingState());
    try {
      final actionCode = _extractPasswordResetCode(codeOrLink);

      // التأكد من صحة الكود قبل التغيير
      await FirebaseAuth.instance.verifyPasswordResetCode(actionCode);

      // تنفيذ التغيير الفعلي
      await FirebaseAuth.instance.confirmPasswordReset(
        code: actionCode,
        newPassword: newPassword,
      );

      emit(AuthPasswordResetSuccessState());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to reset password';
      if (e.code == 'expired-action-code')
        errorMessage = 'Reset code has expired';
      if (e.code == 'invalid-action-code')
        errorMessage = 'Invalid reset code or link';
      if (e.code == 'weak-password')
        errorMessage = 'The password provided is too weak';

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

      if (googleUser != null) {
        // 5. Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // 6. Create a new credential for Firebase
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 7. Sign in to Firebase with the credential
        await FirebaseAuth.instance.signInWithCredential(credential);

        // 8. Success! Emit success state
        emit(AuthSuccessState());
      } else {
        // User canceled the sign-in flow
        emit(AuthErrorState(error: "No account selected"));
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors
      emit(
        AuthErrorState(error: e.message ?? "Firebase Authentication Failed"),
      );
    } catch (e) {
      // Handle any other errors
      emit(
        AuthErrorState(error: "An unexpected error occurred: ${e.toString()}"),
      );
    }
  }

  Future<void> login() async {
    emit(AuthLoadingState());
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        emit(AuthErrorState(error: 'Account not found'));
        return;
      }

      await user.reload();
      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        emit(
          AuthErrorState(error: 'Please verify your email before logging in'),
        );
        return;
      }

      emit(AuthSuccessState());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthErrorState(error: 'Account not found'));
      } else if (e.code == 'wrong-password') {
        emit(AuthErrorState(error: 'Wrong password'));
      } else if (e.code == 'invalid-credential') {
        emit(AuthErrorState(error: 'Invalid credentials'));
      } else {
        emit(AuthErrorState(error: e.message ?? 'Unexpected error'));
      }
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }
}
