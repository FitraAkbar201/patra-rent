import 'package:car_rental_system/enums/vehicle_category.dart';
import 'package:car_rental_system/enums/vehicle_status.dart';
import 'package:car_rental_system/exceptions/rental_rule_exception.dart';
import 'package:car_rental_system/models/customer.dart';
import 'package:car_rental_system/models/rental.dart';
import 'package:car_rental_system/models/rental_desk.dart';
import 'package:car_rental_system/models/rental_period.dart';
import 'package:car_rental_system/models/vehicle.dart';
import 'package:car_rental_system/utils/format.dart';

void printSection(String title) {
  print('\n=== $title ===');
}

/// Menjalankan [action] yang seharusnya melanggar aturan domain, lalu
/// menampilkan pesan penolakannya. Program tetap berjalan ke bagian berikut.
void expectViolation(String title, void Function() action) {
  try {
    action();
    print('[BUG] $title: seharusnya ditolak, tetapi lolos.');
  } on RentalRuleException catch (e) {
    print('[DITOLAK] $title');
    print('          ${e.message}');
  }
}

void main() {
  print('==================================');
  print('      P A T R A   R E N T');
  print('   Simulasi Rental Mobil (Dart)');
  print('==================================');

  // 1. Armada
  printSection('Armada');
  final desk = RentalDesk('Nusantara Rent');
  final brio = Vehicle(
    plateNumber: 'ab 5678 cd',
    brand: 'Honda',
    model: 'Brio',
    category: VehicleCategory.economy,
    dailyRate: 300000,
    odometerKm: 12000,
  );
  final avanza = Vehicle(
    plateNumber: 'H 1234 AB',
    brand: 'Toyota',
    model: 'Avanza',
    category: VehicleCategory.mpv,
    dailyRate: 450000,
    odometerKm: 35200,
  );
  final fortuner = Vehicle(
    plateNumber: 'K 9012 EF',
    brand: 'Toyota',
    model: 'Fortuner',
    category: VehicleCategory.suv,
    dailyRate: 900000,
    odometerKm: 21000,
  );
  final alphard = Vehicle(
    plateNumber: 'B 3456 GH',
    brand: 'Toyota',
    model: 'Alphard',
    category: VehicleCategory.luxury,
    dailyRate: 2000000,
    odometerKm: 8000,
  );
  for (final vehicle in [brio, avanza, fortuner, alphard]) {
    desk.addVehicle(vehicle);
  }
  alphard.changeStatus(VehicleStatus.maintenance, DateTime(2026, 10, 1));
  for (final vehicle in desk.fleet) {
    print(vehicle.displayInfo());
  }
  expectViolation(
    'Mendaftarkan plat yang sama dua kali',
    () => desk.addVehicle(
      Vehicle(
        plateNumber: 'H 1234 AB',
        brand: 'Daihatsu',
        model: 'Xenia',
        category: VehicleCategory.mpv,
        dailyRate: 400000,
      ),
    ),
  );

  // 2. Pelanggan
  printSection('Pelanggan');
  final budi = Customer(
    id: 'C-001',
    name: 'Budi Santoso',
    phone: '081234567890',
    licenseExpiry: DateTime(2028, 6, 30),
  );
  final sari = Customer(
    id: 'C-002',
    name: 'Sari Wulandari',
    licenseExpiry: DateTime(2026, 10, 20),
  );
  print(budi.displayInfo());
  print(sari.displayInfo());

  // 3. Reservasi
  printSection('Reservasi');
  final r1 = desk.reserve(
    id: 'R-001',
    customer: budi,
    vehicle: avanza,
    period: RentalPeriod(start: DateTime(2026, 10, 10), end: DateTime(2026, 10, 13)),
    at: DateTime(2026, 10, 4, 9, 0),
  );
  print(r1.displaySummary());

  expectViolation(
    'Sari memesan Avanza yang sama pada 12-15 Oktober (bentrok)',
    () => desk.reserve(
      id: 'R-002',
      customer: sari,
      vehicle: avanza,
      period: RentalPeriod(start: DateTime(2026, 10, 12), end: DateTime(2026, 10, 15)),
      at: DateTime(2026, 10, 4, 10, 0),
    ),
  );
  expectViolation(
    'Sari memesan Fortuner 18-25 Oktober, padahal SIM habis 20 Oktober',
    () => desk.reserve(
      id: 'R-002',
      customer: sari,
      vehicle: fortuner,
      period: RentalPeriod(start: DateTime(2026, 10, 18), end: DateTime(2026, 10, 25)),
      at: DateTime(2026, 10, 4, 10, 5),
    ),
  );
  expectViolation(
    'Memesan Alphard yang sedang dalam perawatan',
    () => desk.reserve(
      id: 'R-002',
      customer: budi,
      vehicle: alphard,
      period: RentalPeriod(start: DateTime(2026, 10, 18), end: DateTime(2026, 10, 20)),
      at: DateTime(2026, 10, 4, 10, 10),
    ),
  );

  final r2 = desk.reserve(
    id: 'R-002',
    customer: sari,
    vehicle: avanza,
    period: RentalPeriod(start: DateTime(2026, 10, 13), end: DateTime(2026, 10, 15)),
    at: DateTime(2026, 10, 4, 10, 15),
  );
  print('\nAvanza pada 13-15 Oktober bisa dipesan Sari, karena Budi kembali '
      'tanggal 13: ${r2.id} (${r2.status.label}).');

  final r3 = desk.reserve(
    id: 'R-003',
    customer: sari,
    vehicle: brio,
    period: RentalPeriod(start: DateTime(2026, 10, 14), end: DateTime(2026, 10, 16)),
    at: DateTime(2026, 10, 4, 10, 20),
  );
  print('${r3.id} dibuat untuk ${r3.vehicle.plateNumber}, ${r3.period}.');

  printSection('Mobil yang masih bebas pada 11-12 Oktober');
  final window = RentalPeriod(start: DateTime(2026, 10, 11), end: DateTime(2026, 10, 12));
  for (final vehicle in desk.availableVehicles(window)) {
    print(vehicle.displayInfo());
  }

  // 4. Pembatalan
  printSection('Pembatalan');
  r2.cancel(DateTime(2026, 10, 5, 8, 0));
  print('${r2.id} sekarang: ${r2.status.label}');
  expectViolation('Membatalkan sewa yang sudah dibatalkan', () => r2.cancel(DateTime(2026, 10, 5)));
  expectViolation('Mengambil mobil dari sewa yang sudah dibatalkan', () => r2.pickUp(DateTime(2026, 10, 13)));

  // 5. Pengambilan
  printSection('Pengambilan Mobil');
  expectViolation('Budi mengambil Avanza sehari sebelum masa sewa', () => r1.pickUp(DateTime(2026, 10, 9, 9, 0)));
  final pickupTime = DateTime(2026, 10, 10, 9, 0);
  r1.pickUp(pickupTime);
  print(avanza.displayInfo());
  final pickup = r1.pickup;
  if (pickup != null) {
    print('Diambil ${formatDateTime(pickup.at)} pada odometer ${pickup.odometerKm} km.');
  }
  expectViolation('Membatalkan sewa yang sedang berjalan', () => r1.cancel(DateTime(2026, 10, 11)));

  // 6. Pengembalian
  printSection('Pengembalian Mobil');
  print('Laporan pengembalian R-001 sebelum dikembalikan: ${r1.report == null ? 'belum ada' : 'ada'}');
  expectViolation(
    'Odometer lebih kecil dari saat diambil',
    () => r1.returnVehicle(at: DateTime(2026, 10, 14, 10, 0), odometerKm: 35100),
  );
  expectViolation(
    'Dikembalikan lebih awal dari waktu pengambilan',
    () => r1.returnVehicle(at: DateTime(2026, 10, 10, 8, 0), odometerKm: 35300),
  );
  expectViolation(
    'Biaya kerusakan tanpa keterangan',
    () => r1.returnVehicle(at: DateTime(2026, 10, 14, 10, 0), odometerKm: 35580, damageFee: 150000),
  );

  r1.returnVehicle(
    at: DateTime(2026, 10, 14, 10, 0),
    odometerKm: 35580,
    damageFee: 150000,
    damageNote: 'Penyok pintu kiri belakang',
  );
  print(r1.displaySummary());
  print('\n${avanza.displayInfo()}');
  expectViolation('Mengembalikan mobil yang sudah dikembalikan', () => r1.returnVehicle(at: DateTime(2026, 10, 15), odometerKm: 35600));

  // 7. Jejak audit (mixin AuditTrail dipakai Rental dan Vehicle)
  printSection('Jejak Audit');
  print('Rental ${r1.id}:');
  for (final entry in r1.auditLog) {
    print('  ${formatDateTime(entry.at)}  ${entry.description}');
  }
  print('Vehicle ${avanza.plateNumber}:');
  for (final entry in avanza.auditLog) {
    print('  ${formatDateTime(entry.at)}  ${entry.description}');
  }

  // 8. Keadaan mustahil yang ditolak sejak objek dibuat
  printSection('Keadaan Mustahil');
  expectViolation(
    'Plat nomor asal-asalan',
    () => Vehicle(plateNumber: 'MOBIL BAGUS', brand: 'Toyota', model: 'Yaris', category: VehicleCategory.economy, dailyRate: 350000),
  );
  expectViolation(
    'Tarif harian nol',
    () => Vehicle(plateNumber: 'D 1 AA', brand: 'Toyota', model: 'Yaris', category: VehicleCategory.economy, dailyRate: 0),
  );
  expectViolation(
    'Nomor telepon berisi huruf',
    () => Customer(id: 'C-003', name: 'Andi', phone: '08ab', licenseExpiry: DateTime(2030, 1, 1)),
  );
  expectViolation(
    'Tanggal selesai sebelum tanggal mulai',
    () => RentalPeriod(start: DateTime(2026, 10, 20), end: DateTime(2026, 10, 18)),
  );
  expectViolation(
    'Sewa 45 hari',
    () => RentalPeriod(start: DateTime(2026, 11, 1), end: DateTime(2026, 12, 16)),
  );
  expectViolation(
    'Mobil dalam perawatan langsung disewa (loncat status)',
    () => alphard.changeStatus(VehicleStatus.rented, DateTime(2026, 10, 5)),
  );

  // 9. Null safety
  printSection('Null Safety');
  print('Telepon ${budi.name}: ${budi.phone ?? '-'}');
  print('Telepon ${sari.name}: ${sari.phone ?? '-'}');
  printReportState(r1);
  printReportState(r3);

  // 10. Rekap
  printSection('Rekap Semua Sewa');
  for (final rental in desk.rentals) {
    print('${rental.id} | ${rental.customer.name} | ${rental.vehicle.plateNumber} | ${rental.status.label} | ${formatRupiah(rental.totalCost)}');
  }
  try {
    desk.rentals.clear();
  } on UnsupportedError {
    print('\nDaftar sewa dari desk.rentals read-only: clear() ditolak Dart.');
  }
}

void printReportState(Rental rental) {
  final report = rental.report;
  if (report == null) {
    print('${rental.id}: belum ada laporan pengembalian (report == null).');
  } else {
    print('${rental.id}: dikembalikan ${formatDateTime(report.returnedAt)}, odometer ${report.odometerKm} km.');
  }
}
