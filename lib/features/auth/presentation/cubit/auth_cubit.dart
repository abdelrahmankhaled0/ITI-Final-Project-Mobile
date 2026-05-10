import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInatialState());
  static AuthCubit get(context) => BlocProvider.of(context);

  final formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
    confirmPasswordController.clear();
  }

  Future<void> register() async {
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

  Future<void> login() async {
    emit(AuthLoadingState());
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
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
