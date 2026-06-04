class AppRegex {
  static bool isEmailValid(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(email);
  }

  static bool isUsernameValid(String username) {
    final regex = RegExp(r'^[A-Za-z]{2,20}\s[A-Za-z]{2,20}$');
    return regex.hasMatch(username.trim());
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
