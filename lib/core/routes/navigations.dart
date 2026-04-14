import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigations {
  static void pushTo(BuildContext context, String newScreen) {
    context.push(newScreen);
  }

  static void pushReplacementTo(BuildContext context, String newScreen) {
    context.pushReplacement(newScreen);
  }

  static void pop(BuildContext context) {
    context.pop();
  }
}
