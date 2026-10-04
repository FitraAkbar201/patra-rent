/// Kelas kendaraan. Menentukan kapasitas dan besar deposit.
///
/// Berbeda kelas hanya berarti berbeda data, bukan berbeda perilaku,
/// itulah sebabnya ini enum dan bukan subclass.
enum VehicleCategory {
  economy('Ekonomi', seats: 5, deposit: 500000),
  mpv('MPV', seats: 7, deposit: 750000),
  suv('SUV', seats: 7, deposit: 1000000),
  luxury('Mewah', seats: 5, deposit: 3000000);

  const VehicleCategory(
    this.label, {
    required this.seats,
    required this.deposit,
  });

  final String label;
  final int seats;

  /// Deposit dalam rupiah, dibayar di awal dan dikembalikan setelah
  /// dipotong denda keterlambatan dan biaya kerusakan.
  final int deposit;
}
