import '../exceptions/rental_rule_exception.dart';

/// Satu catatan kejadian beserta waktunya.
class AuditEntry {
  const AuditEntry(this.at, this.description);

  final DateTime at;
  final String description;
}

/// Jejak kejadian yang hanya bisa bertambah, tidak bisa dihapus dari luar.
///
/// Dipakai Vehicle (kapan masuk perawatan, kapan disewa) dan Rental
/// (kapan dipesan, diambil, dikembalikan). Keduanya tidak sekerabat,
/// tetapi sama-sama butuh bukti kronologi kalau terjadi sengketa.
mixin AuditTrail {
  final List<AuditEntry> _auditLog = [];

  List<AuditEntry> get auditLog => List.unmodifiable(_auditLog);

  void recordEvent(DateTime at, String description) {
    final text = description.trim();
    if (text.isEmpty) {
      throw const RentalRuleException('Catatan kejadian tidak boleh kosong.');
    }
    _auditLog.add(AuditEntry(at, text));
  }
}
