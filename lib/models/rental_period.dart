import '../exceptions/rental_rule_exception.dart';
import '../utils/format.dart';

/// Rentang tanggal sewa. Tanggal mulai dihitung, tanggal selesai adalah
/// hari mobil kembali, sehingga 10 s.d. 13 berarti 3 hari sewa dan
/// mobil bisa dipesan orang lain mulai tanggal 13.
class RentalPeriod {
  RentalPeriod._(this.start, this.end);

  factory RentalPeriod({required DateTime start, required DateTime end}) {
    final from = dateOnly(start);
    final until = dateOnly(end);
    if (!until.isAfter(from)) {
      throw const RentalRuleException(
        'Tanggal selesai harus setelah tanggal mulai.',
      );
    }
    final days = until.difference(from).inDays;
    if (days > maxDays) {
      throw RentalRuleException(
        'Lama sewa maksimal $maxDays hari (diminta $days hari).',
      );
    }
    return RentalPeriod._(from, until);
  }

  static const int maxDays = 30;

  final DateTime start;
  final DateTime end;

  int get days => end.difference(start).inDays;

  bool overlaps(RentalPeriod other) =>
      start.isBefore(other.end) && other.start.isBefore(end);

  @override
  String toString() =>
      '${formatDate(start)} s.d. ${formatDate(end)} ($days hari)';
}
