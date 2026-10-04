/// Membuang jam dari sebuah tanggal. Hasilnya UTC supaya selisih hari
/// selalu kelipatan 24 jam, tidak terpengaruh zona waktu.
DateTime dateOnly(DateTime value) =>
    DateTime.utc(value.year, value.month, value.day);

String formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day-$month-${value.year}';
}

String formatDateTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${formatDate(value)} $hour:$minute';
}

/// Contoh: 1350000 menjadi "Rp1.350.000".
String formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  final sign = amount < 0 ? '-' : '';
  return '${sign}Rp$buffer';
}
