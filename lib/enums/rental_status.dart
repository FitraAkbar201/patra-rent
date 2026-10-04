/// Siklus hidup satu transaksi sewa.
enum RentalStatus {
  reserved('Dipesan'),
  active('Berjalan'),
  returned('Dikembalikan'),
  cancelled('Dibatalkan');

  const RentalStatus(this.label);

  final String label;

  Set<RentalStatus> get allowedNext => switch (this) {
        RentalStatus.reserved => {RentalStatus.active, RentalStatus.cancelled},
        RentalStatus.active => {RentalStatus.returned},
        RentalStatus.returned || RentalStatus.cancelled => <RentalStatus>{},
      };

  bool canChangeTo(RentalStatus next) => allowedNext.contains(next);

  /// Hanya sewa yang dipesan atau berjalan yang "memegang" kendaraan,
  /// artinya mencegah sewa lain pada tanggal yang sama.
  bool get holdsVehicle =>
      this == RentalStatus.reserved || this == RentalStatus.active;
}
