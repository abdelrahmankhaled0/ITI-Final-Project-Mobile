import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigations {
  static void pushTo(BuildContext context, String newScreen, {Object? extra}) {
    context.push(newScreen, extra: extra);
  }

  static void pushReplacementTo(
    BuildContext context,
    String newScreen, {
    Object? extra,
  }) {
    context.pushReplacement(newScreen, extra: extra);
  }

  static void pop(BuildContext context) {
    context.pop();
  }
}
