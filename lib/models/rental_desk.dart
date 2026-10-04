import '../enums/vehicle_status.dart';
import '../exceptions/rental_rule_exception.dart';
import '../utils/format.dart';
import 'customer.dart';
import 'rental.dart';
import 'rental_period.dart';
import 'vehicle.dart';

/// Kantor rental. Memiliki armada dan semua transaksi sewa (composition),
/// sehingga hanya di sini aturan lintas-transaksi bisa ditegakkan,
/// yaitu satu mobil tidak boleh disewa dua orang pada tanggal yang beririsan.
class RentalDesk {
  RentalDesk(this.name) {
    if (name.trim().isEmpty) {
      throw const RentalRuleException('Nama rental tidak boleh kosong.');
    }
  }

  final String name;
  final List<Vehicle> _fleet = [];
  final List<Rental> _rentals = [];

  List<Vehicle> get fleet => List.unmodifiable(_fleet);
  List<Rental> get rentals => List.unmodifiable(_rentals);

  void addVehicle(Vehicle vehicle) {
    final exists = _fleet.any((v) => v.plateNumber == vehicle.plateNumber);
    if (exists) {
      throw RentalRuleException(
        'Kendaraan ${vehicle.plateNumber} sudah terdaftar di armada.',
      );
    }
    _fleet.add(vehicle);
  }

  Rental? findRental(String id) =>
      _rentals.where((rental) => rental.id == id).firstOrNull;

  /// Mobil yang tidak dalam perawatan dan tidak bentrok pada [period].
  List<Vehicle> availableVehicles(RentalPeriod period) => _fleet
      .where((v) =>
          v.status != VehicleStatus.maintenance &&
          _conflictFor(v, period) == null)
      .toList();

  Rental reserve({
    required String id,
    required Customer customer,
    required Vehicle vehicle,
    required RentalPeriod period,
    required DateTime at,
  }) {
    if (!_fleet.contains(vehicle)) {
      throw RentalRuleException(
        'Kendaraan ${vehicle.plateNumber} bukan bagian dari armada $name.',
      );
    }
    if (findRental(id) != null) {
      throw RentalRuleException('ID sewa "$id" sudah dipakai.');
    }
    final rental = Rental(
      id: id,
      customer: customer,
      vehicle: vehicle,
      period: period,
      createdAt: at,
    );
    final conflict = _conflictFor(vehicle, period);
    if (conflict != null) {
      throw RentalRuleException(
        'Kendaraan ${vehicle.plateNumber} sudah dipegang sewa ${conflict.id} '
        'pada ${conflict.period}; bentrok dengan ${formatDate(period.start)} '
        's.d. ${formatDate(period.end)}.',
      );
    }
    _rentals.add(rental);
    return rental;
  }

  Rental? _conflictFor(Vehicle vehicle, RentalPeriod period) {
    for (final rental in _rentals) {
      if (rental.vehicle == vehicle &&
          rental.status.holdsVehicle &&
          rental.period.overlaps(period)) {
        return rental;
      }
    }
    return null;
  }
}
