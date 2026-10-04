/// Bukti pengambilan kendaraan. Tidak berubah setelah dibuat.
class PickupRecord {
  const PickupRecord({required this.at, required this.odometerKm});

  final DateTime at;
  final int odometerKm;
}
