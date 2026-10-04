/// Kondisi fisik kendaraan, beserta perpindahan yang diizinkan.
enum VehicleStatus {
  available('Tersedia'),
  rented('Sedang disewa'),
  maintenance('Dalam perawatan');

  const VehicleStatus(this.label);

  final String label;

  /// Mobil yang sedang disewa tidak bisa langsung masuk perawatan,
  /// dan mobil dalam perawatan tidak bisa langsung disewa.
  Set<VehicleStatus> get allowedNext => switch (this) {
        VehicleStatus.available => {
            VehicleStatus.rented,
            VehicleStatus.maintenance,
          },
        VehicleStatus.rented => {VehicleStatus.available},
        VehicleStatus.maintenance => {VehicleStatus.available},
      };

  bool canChangeTo(VehicleStatus next) => allowedNext.contains(next);
}
