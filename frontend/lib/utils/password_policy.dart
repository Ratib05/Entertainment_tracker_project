class PasswordPolicy {
  static const int minLength = 8;
  static const String minLengthDescription = 'At least 8 characters';
  static const String uppercaseDescription = 'At least 1 uppercase letter';
  static const String numberDescription = 'At least 1 number';
  static const String specialDescription = 'At least 1 special character (!@#\$%^&*)';

  static bool hasMinLength(String password) => password.length >= minLength;
  static bool hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));
  static bool hasNumber(String password) => password.contains(RegExp(r'[0-9]'));
  static bool hasSpecialChar(String password) =>
      password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:\'",.<>?]'));

  static bool isValid(String password) =>
      hasMinLength(password) &&
      hasUppercase(password) &&
      hasNumber(password) &&
      hasSpecialChar(password);

  static List<PasswordRequirement> getRequirements(String password) {
    return [
      PasswordRequirement(
        label: minLengthDescription,
        isMet: hasMinLength(password),
      ),
      PasswordRequirement(
        label: uppercaseDescription,
        isMet: hasUppercase(password),
      ),
      PasswordRequirement(
        label: numberDescription,
        isMet: hasNumber(password),
      ),
      PasswordRequirement(
        label: specialDescription,
        isMet: hasSpecialChar(password),
      ),
    ];
  }
}

class PasswordRequirement {
  final String label;
  final bool isMet;

  PasswordRequirement({
    required this.label,
    required this.isMet,
  });
}
