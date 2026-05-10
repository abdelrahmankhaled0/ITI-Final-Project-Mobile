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

  register() async {
    emit(AuthLoadingState());
    try {
      var credintial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      User? user = credintial.user;
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "name": nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'uid': user.uid,
      });
      emit(AuthSuccessState());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthErrorState(error: 'weak password'));
      } else if (e.code == 'email-already-in-use') {
        emit(AuthErrorState(error: 'this account already exist'));
      } else {
        emit(AuthErrorState(error: 'something went wrong'));
      }
    } catch (e) {
      emit(AuthErrorState(error: e.toString()));
    }
  }

  login() async {
    emit(AuthLoadingState());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
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
