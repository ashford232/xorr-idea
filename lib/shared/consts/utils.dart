abstract class Utils {
  static final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? emailValidator(String? value) {
    if (value == "" || value == null) {
      return "Email is required.";
    }
    if (!Utils.emailRegex.hasMatch(value)) {
      return "Enter a valid email.";
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == "" || value == null) {
      return "Password is required.";
    }
    if (value.length < 6) {
      return "Enter a strong password.";
    }
    return null;
  }
}
