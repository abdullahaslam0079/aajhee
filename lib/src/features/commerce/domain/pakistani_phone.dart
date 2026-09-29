/// Pakistani mobile validation / E.164 normalization (+923XXXXXXXXX).
library;

/// Accepts 03XX-XXXXXXX, 03XXXXXXXXX, +92 3XX XXXXXXX, +923XXXXXXXXX.
String? normalizePakistaniMobile(String? value) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) return null;

  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0092')) {
    digits = digits.substring(2);
  }
  String normalized;
  if (digits.startsWith('92') && digits.length == 12) {
    normalized = '+$digits';
  } else if (digits.startsWith('0') && digits.length == 11) {
    normalized = '+92${digits.substring(1)}';
  } else if (digits.startsWith('3') && digits.length == 10) {
    normalized = '+92$digits';
  } else {
    return null;
  }

  if (!RegExp(r'^\+923\d{9}$').hasMatch(normalized)) return null;
  return normalized;
}

String? validatePakistaniMobile(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Mobile number is required';
  }
  if (normalizePakistaniMobile(value) == null) {
    return 'Enter a Pakistani mobile (03XX-XXXXXXX or +92 3XX XXXXXXX)';
  }
  return null;
}

/// Display helper: +923001234567 → 0300 1234567
String formatPakistaniMobileLocal(String? e164) {
  final normalized = normalizePakistaniMobile(e164);
  if (normalized == null) return e164?.trim() ?? '';
  final national = '0${normalized.substring(3)}'; // 03XXXXXXXXX
  return '${national.substring(0, 4)} ${national.substring(4)}';
}

/// Display helper: +923001234567 → +92 300 1234567
String formatPakistaniMobileInternational(String? value) {
  final normalized = normalizePakistaniMobile(value);
  if (normalized == null) {
    final raw = value?.trim() ?? '';
    return raw;
  }
  final rest = normalized.substring(3); // 3XXXXXXXXX
  return '+92 ${rest.substring(0, 3)} ${rest.substring(3)}';
}
