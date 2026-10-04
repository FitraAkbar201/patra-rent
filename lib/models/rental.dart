import '../enums/rental_status.dart';
import '../enums/vehicle_status.dart';
import '../exceptions/rental_rule_exception.dart';
import '../mixins/audit_trail.dart';
import '../utils/format.dart';
import 'customer.dart';
import 'pickup_record.dart';
import 'rental_period.dart';
import 'return_report.dart';
import 'vehicle.dart';

/// Satu transaksi sewa: siapa menyewa mobil apa, kapan, dan berapa biayanya.
class Rental with AuditTrail {
  Rental({
    required this.id,
    required this.customer,
    required this.vehicle,
    required this.period,
    required DateTime createdAt,
  }) {
    if (id.trim().isEmpty) {
      throw const RentalRuleException('ID sewa tidak boleh kosong.');
    }
    if (vehicle.status == VehicleStatus.maintenance) {
      throw RentalRuleException(
        'Kendaraan ${vehicle.plateNumber} sedang dalam perawatan '
        'dan tidak bisa dipesan.',
      );
    }
    if (!customer.isLicenseValidOn(period.end)) {
      throw RentalRuleException(
        'SIM ${customer.name} berakhir ${formatDate(customer.licenseExpiry)}, '
        'sebelum masa sewa selesai (${formatDate(period.end)}).',
      );
    }
    recordEvent(createdAt, 'Reservasi dibuat untuk $period');
  }

  /// Denda per hari terlambat, sebagai persen dari tarif harian.
  static const int lateFeePercent = 150;

  final String id;
  final Customer customer;
  final Vehicle vehicle;
  final RentalPeriod period;

  RentalStatus _status = RentalStatus.reserved;
  PickupRecord? _pickup;
  ReturnReport? _report;

  RentalStatus get status => _status;

  /// Kosong sampai mobil diambil.
  PickupRecord? get pickup => _pickup;

  /// Kosong sampai mobil dikembalikan.
  ReturnReport? get report => _report;

  // --- Biaya ---

  int get rentalCost => period.days * vehicle.dailyRate;

  int get deposit => vehicle.category.deposit;

  /// Keterlambatan dihitung per hari kalender setelah tanggal selesai.
  int get lateDays {
    final returned = _report;
    if (returned == null) {
      return 0;
    }
    final days = dateOnly(returned.returnedAt).difference(period.end).inDays;
    return days > 0 ? days : 0;
  }

  int get lateFee => lateDays * vehicle.dailyRate * lateFeePercent ~/ 100;

  int get damageFee => _report?.damageFee ?? 0;

  int get totalCost => rentalCost + lateFee + damageFee;

  /// Deposit yang dikembalikan setelah dipotong denda dan kerusakan.
  int get depositRefund {
    if (_report == null) {
      return 0;
    }
    final balance = deposit - lateFee - damageFee;
    return balance > 0 ? balance : 0;
  }

  /// Kekurangan yang harus dibayar kalau denda dan kerusakan melebihi deposit.
  int get additionalPayment {
    if (_report == null) {
      return 0;
    }
    final shortfall = lateFee + damageFee - deposit;
    return shortfall > 0 ? shortfall : 0;
  }

  // --- Perubahan status ---

  void pickUp(DateTime at) {
    _requireTransition(RentalStatus.active);
    final day = dateOnly(at);
    if (day.isBefore(period.start) || !day.isBefore(period.end)) {
      throw RentalRuleException(
        'Pengambilan harus dalam masa sewa ($period), '
        'diminta ${formatDate(at)}.',
      );
    }
    if (vehicle.status != VehicleStatus.available) {
      throw RentalRuleException(
        'Kendaraan ${vehicle.plateNumber} belum bisa diambil '
        '(status: ${vehicle.status.label}).',
      );
    }
    vehicle.changeStatus(VehicleStatus.rented, at);
    _pickup = PickupRecord(at: at, odometerKm: vehicle.odometerKm);
    _status = RentalStatus.active;
    recordEvent(at, 'Kendaraan diambil, odometer ${vehicle.odometerKm} km');
  }

  void returnVehicle({
    required DateTime at,
    required int odometerKm,
    int damageFee = 0,
    String? damageNote,
  }) {
    final taken = _pickup;
    if (_status != RentalStatus.active || taken == null) {
      throw RentalRuleException(
        'Hanya sewa yang sedang berjalan yang bisa dikembalikan '
        '(status: ${_status.label}).',
      );
    }
    if (at.isBefore(taken.at)) {
      throw RentalRuleException(
        'Waktu pengembalian ${formatDateTime(at)} lebih awal dari '
        'waktu pengambilan ${formatDateTime(taken.at)}.',
      );
    }
    if (odometerKm < taken.odometerKm) {
      throw RentalRuleException(
        'Odometer saat kembali ($odometerKm km) lebih kecil dari '
        'saat diambil (${taken.odometerKm} km).',
      );
    }
    final returned = ReturnReport(
      returnedAt: at,
      odometerKm: odometerKm,
      damageFee: damageFee,
      damageNote: damageNote,
    );
    vehicle.updateOdometer(odometerKm);
    vehicle.changeStatus(VehicleStatus.available, at);
    _report = returned;
    _status = RentalStatus.returned;
    recordEvent(
      at,
      'Kendaraan dikembalikan, odometer $odometerKm km, '
      'terlambat $lateDays hari',
    );
  }

  void cancel(DateTime at) {
    _requireTransition(RentalStatus.cancelled);
    _status = RentalStatus.cancelled;
    recordEvent(at, 'Reservasi dibatalkan');
  }

  String displaySummary() {
    final buffer = StringBuffer()
      ..writeln('Sewa       : $id [${_status.label}]')
      ..writeln('Pelanggan  : ${customer.name}')
      ..writeln('Kendaraan  : ${vehicle.brand} ${vehicle.model} '
          '(${vehicle.plateNumber})')
      ..writeln('Periode    : $period')
      ..writeln('Biaya sewa : ${formatRupiah(rentalCost)} '
          '(${period.days} hari x ${formatRupiah(vehicle.dailyRate)})')
      ..writeln('Deposit    : ${formatRupiah(deposit)}');

    final returned = _report;
    if (returned != null) {
      final note = returned.damageNote;
      final noteText = note == null ? '' : ' ($note)';
      buffer
        ..writeln('Denda telat: ${formatRupiah(lateFee)} ($lateDays hari)')
        ..writeln('Kerusakan  : ${formatRupiah(damageFee)}$noteText')
        ..writeln('Total biaya: ${formatRupiah(totalCost)}')
        ..writeln('Deposit kembali: ${formatRupiah(depositRefund)}')
        ..writeln('Bayar tambahan : ${formatRupiah(additionalPayment)}');
    }
    return buffer.toString().trimRight();
  }

  void _requireTransition(RentalStatus next) {
    if (!_status.canChangeTo(next)) {
      throw RentalRuleException(
        'Status sewa tidak bisa berubah dari "${_status.label}" '
        'ke "${next.label}".',
      );
    }
  }
}
