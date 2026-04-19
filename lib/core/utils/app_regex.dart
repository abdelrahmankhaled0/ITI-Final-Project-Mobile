class AppRegex {
  static bool isEmailValid(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(email);
  }

  static bool isUsernameValid(String username) {
    final regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{2,17}$');
    return regex.hasMatch(username);
  }

  static bool isPasswordValid(String password) {
    final regex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(password);
  }

  static bool isEgyptianPhoneValid(String phone) {
    final regex = RegExp(r'^01[0125][0-9]{8}$');
    return regex.hasMatch(phone);
  }
}
