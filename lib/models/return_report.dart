import '../exceptions/rental_rule_exception.dart';

/// Laporan saat kendaraan dikembalikan. Tidak berubah setelah dibuat.
class ReturnReport {
  ReturnReport({
    required this.returnedAt,
    required this.odometerKm,
    this.damageFee = 0,
    this.damageNote,
  }) {
    if (odometerKm < 0) {
      throw const RentalRuleException('Odometer tidak boleh negatif.');
    }
    if (damageFee < 0) {
      throw const RentalRuleException('Biaya kerusakan tidak boleh negatif.');
    }
    final note = damageNote;
    if (damageFee > 0 && (note == null || note.trim().isEmpty)) {
      throw const RentalRuleException(
        'Biaya kerusakan harus disertai keterangan kerusakan.',
      );
    }
  }

  final DateTime returnedAt;
  final int odometerKm;
  final int damageFee;

  /// Boleh kosong kalau mobil kembali tanpa kerusakan, tetapi wajib
  /// terisi kalau ada biaya kerusakan.
  final String? damageNote;
}
