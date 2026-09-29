/// PKR display helpers — e.g. `Rs 2,620` or `Rs 2,620.50`.
library;

String formatRs(dynamic value, {String empty = '—'}) {
  final number = _asNum(value);
  if (number == null) return empty;
  return 'Rs ${_groupDigits(number)}';
}

String? formatRsOrNull(dynamic value) {
  final number = _asNum(value);
  if (number == null) return null;
  return 'Rs ${_groupDigits(number)}';
}

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    final cleaned = value.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    return num.tryParse(cleaned);
  }
  return null;
}

String _groupDigits(num value) {
  final isWhole = value % 1 == 0;
  final raw = isWhole
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
  final parts = raw.split('.');
  final intPart = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    final fromEnd = intPart.length - i;
    buffer.write(intPart[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
  }
  if (parts.length > 1) buffer.write('.${parts[1]}');
  return buffer.toString();
}
