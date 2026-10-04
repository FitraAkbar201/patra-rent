import '../exceptions/rental_rule_exception.dart';
import '../utils/format.dart';

/// Penyewa. SIM wajib ada; nomor telepon boleh tidak diisi.
class Customer {
  Customer({
    required this.id,
    required this.name,
    required this.licenseExpiry,
    this.phone,
  }) {
    if (id.trim().isEmpty) {
      throw const RentalRuleException('ID pelanggan tidak boleh kosong.');
    }
    if (name.trim().isEmpty) {
      throw const RentalRuleException('Nama pelanggan tidak boleh kosong.');
    }
    final number = phone;
    if (number != null && !_phonePattern.hasMatch(number)) {
      throw RentalRuleException('Nomor telepon "$number" tidak valid.');
    }
  }

  static final RegExp _phonePattern = RegExp(r'^\+?\d{8,15}$');

  final String id;
  final String name;

  /// Tanggal terakhir SIM masih berlaku.
  final DateTime licenseExpiry;

  /// Opsional: pelanggan bisa menyewa tanpa mencantumkan nomor telepon.
  final String? phone;

  bool isLicenseValidOn(DateTime date) =>
      !dateOnly(date).isAfter(dateOnly(licenseExpiry));

  String displayInfo() => '$name [$id] | HP: ${phone ?? '-'} | '
      'SIM berlaku s.d. ${formatDate(licenseExpiry)}';
}
