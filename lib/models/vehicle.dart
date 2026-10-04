import '../enums/vehicle_category.dart';
import '../enums/vehicle_status.dart';
import '../exceptions/rental_rule_exception.dart';
import '../mixins/audit_trail.dart';
import '../utils/format.dart';

/// Satu unit mobil di armada. Plat nomor menjadi identitasnya.
class Vehicle with AuditTrail {
  Vehicle({
    required String plateNumber,
    required this.brand,
    required this.model,
    required this.category,
    required this.dailyRate,
    int odometerKm = 0,
  })  : plateNumber = _normalizePlate(plateNumber),
        _odometerKm = odometerKm {
    if (brand.trim().isEmpty || model.trim().isEmpty) {
      throw const RentalRuleException('Merek dan model tidak boleh kosong.');
    }
    if (dailyRate <= 0) {
      throw const RentalRuleException('Tarif harian harus lebih dari nol.');
    }
    if (odometerKm < 0) {
      throw const RentalRuleException('Odometer tidak boleh negatif.');
    }
  }

  static final RegExp _platePattern = RegExp(r'^[A-Z]{1,2} \d{1,4} [A-Z]{1,3}$');

  final String plateNumber;
  final String brand;
  final String model;
  final VehicleCategory category;

  /// Tarif per hari dalam rupiah (bilangan bulat, bukan double, supaya
  /// tidak ada selisih pembulatan).
  final int dailyRate;

  int _odometerKm;
  VehicleStatus _status = VehicleStatus.available;

  int get odometerKm => _odometerKm;
  VehicleStatus get status => _status;

  void changeStatus(VehicleStatus next, DateTime at) {
    if (!_status.canChangeTo(next)) {
      throw RentalRuleException(
        'Kendaraan $plateNumber tidak bisa berubah dari '
        '"${_status.label}" ke "${next.label}".',
      );
    }
    recordEvent(at, 'Status ${_status.label} -> ${next.label}');
    _status = next;
  }

  /// Odometer hanya boleh maju.
  void updateOdometer(int km) {
    if (km < _odometerKm) {
      throw RentalRuleException(
        'Odometer $plateNumber tidak boleh mundur '
        '(sekarang $_odometerKm km, diminta $km km).',
      );
    }
    _odometerKm = km;
  }

  String displayInfo() => '$plateNumber | $brand $model | '
      '${category.label} (${category.seats} kursi) | '
      '${formatRupiah(dailyRate)}/hari | ${_status.label} | $_odometerKm km';

  static String _normalizePlate(String raw) {
    final plate = raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    if (!_platePattern.hasMatch(plate)) {
      throw RentalRuleException(
        'Plat nomor "$raw" tidak valid. Contoh format: H 1234 AB.',
      );
    }
    return plate;
  }
}
