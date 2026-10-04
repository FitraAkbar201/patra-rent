/// Dilempar setiap kali sebuah aturan domain rental mobil dilanggar.
///
/// Dibuat terpisah dari error teknis Dart (RangeError, StateError, dst.)
/// supaya pelanggaran aturan bisnis bisa dikenali dan ditangani sendiri.
class RentalRuleException implements Exception {
  const RentalRuleException(this.message);

  final String message;

  @override
  String toString() => 'RentalRuleException: $message';
}
