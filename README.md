# Patra Rent — Sistem Simulasi Rental Mobil

Patra Rent merupakan proyek sederhana berbasis Dart yang digunakan untuk menyimulasikan proses penyewaan mobil pada sebuah tempat rental. Proyek ini dibuat untuk memenuhi tugas mata kuliah Pemrograman Perangkat Bergerak (PPB), dengan fokus pada penerapan konsep Object-Oriented Programming (OOP).

Program ini berjalan melalui terminal tanpa menggunakan Flutter atau antarmuka grafis. Proses penyewaan dikelola melalui beberapa kelas yang memiliki tanggung jawab masing-masing, mulai dari pengelolaan data pelanggan dan kendaraan hingga proses pengembalian mobil.

## Gambaran Proyek

Dalam sistem ini, sebuah tempat rental memiliki beberapa kendaraan yang dapat disewakan kepada pelanggan. Setiap transaksi penyewaan memiliki periode sewa, status transaksi, serta catatan ketika kendaraan diambil dan dikembalikan.

Sistem juga menerapkan sejumlah aturan untuk menghindari kesalahan selama proses penyewaan. Contohnya, kendaraan tidak dapat disewa oleh dua pelanggan pada periode yang saling bertabrakan, pelanggan harus memiliki SIM yang masih berlaku, dan kendaraan yang sedang dalam perawatan tidak dapat dipesan.

Melalui proyek ini, konsep OOP diterapkan untuk memisahkan data, perilaku, dan aturan bisnis agar kode lebih mudah dibaca dan dikelola.

## Fitur Program

Beberapa proses yang dapat disimulasikan dalam program Patra Rent antara lain:

- **Pengelolaan kendaraan**  
  Menyimpan informasi kendaraan, kategori mobil, tarif sewa harian, dan status kendaraan.

- **Pengelolaan pelanggan**  
  Menyimpan data pelanggan serta memeriksa masa berlaku SIM sebelum penyewaan dilakukan.

- **Reservasi mobil**  
  Membuat transaksi penyewaan berdasarkan kendaraan, pelanggan, dan periode sewa yang dipilih.

- **Pemeriksaan ketersediaan kendaraan**  
  Memastikan jadwal penyewaan tidak bertabrakan dengan transaksi lain untuk kendaraan yang sama.

- **Pengambilan kendaraan**  
  Mencatat proses pengambilan mobil, termasuk waktu dan informasi odometer.

- **Pengembalian kendaraan**  
  Mencatat informasi pengembalian dan kondisi kendaraan setelah masa sewa berakhir.

- **Perhitungan biaya sewa dan denda**  
  Menghitung biaya berdasarkan tarif harian serta memperhitungkan denda keterlambatan dan biaya kerusakan sesuai aturan yang diterapkan.

- **Pencatatan aktivitas**  
  Menyimpan jejak aktivitas tertentu pada kendaraan dan transaksi penyewaan melalui mixin `AuditTrail`.

- **Validasi aturan bisnis**  
  Menggunakan custom exception untuk menangani kondisi yang tidak diperbolehkan dalam proses penyewaan.

## Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Dart | Bahasa pemrograman utama |
| Dart SDK | Menjalankan program dan mengelola dependensi |
| Visual Studio Code | Editor untuk menulis dan mengelola kode |
| Git | Pengelolaan versi kode, jika diperlukan |

Proyek ini menggunakan Dart murni dan tidak memerlukan Flutter untuk menjalankan simulasi.

## Keterangan Struktur Folder

- `bin/main.dart` merupakan titik awal program yang menjalankan simulasi rental mobil.
- `lib/models/` berisi kelas-kelas utama yang merepresentasikan pelanggan, kendaraan, periode sewa, dan transaksi.
- `lib/enums/` berisi enum untuk kategori kendaraan dan status kendaraan maupun transaksi.
- `lib/exceptions/` berisi custom exception untuk menangani pelanggaran aturan bisnis.
- `lib/mixins/` berisi mixin yang digunakan untuk mencatat aktivitas.
- `lib/utils/` berisi fungsi pendukung untuk pemformatan data.
- `pubspec.yaml` berisi informasi dan konfigurasi proyek Dart.
- `analysis_options.yaml` berisi konfigurasi analisis kode Dart.

## Penerapan Konsep OOP

Proyek Patra Rent menerapkan beberapa konsep OOP sesuai kebutuhan sistem penyewaan mobil.

### 1. Class dan Object

Program menggunakan beberapa kelas yang saling berhubungan, yaitu:

| Kelas | Tanggung Jawab |
|---|---|
| `Customer` | Menyimpan informasi pelanggan dan data SIM. |
| `Vehicle` | Mengelola informasi kendaraan, tarif, status, dan odometer. |
| `Rental` | Mengelola transaksi serta aturan penyewaan. |
| `RentalPeriod` | Menyimpan periode sewa dan memeriksa bentrokan tanggal. |
| `RentalDesk` | Mengelola armada dan transaksi penyewaan. |
| `PickupRecord` | Menyimpan catatan pengambilan kendaraan. |
| `ReturnReport` | Menyimpan informasi pengembalian kendaraan. |

Setiap kelas memiliki tanggung jawab yang berbeda sehingga aturan bisnis tidak seluruhnya ditempatkan dalam satu kelas.

### 2. Composition

Komposisi digunakan untuk menggambarkan hubungan antara objek yang bekerja sama dalam sistem rental.

Sebagai contoh, `RentalDesk` mengelola daftar kendaraan dan transaksi penyewaan. Sementara itu, objek `Rental` berhubungan dengan periode sewa serta catatan pengambilan dan pengembalian kendaraan.

Pendekatan ini dipilih karena objek-objek tersebut memiliki fungsi yang berbeda, tetapi saling dibutuhkan dalam proses penyewaan.

### 3. Mixin

Mixin `AuditTrail` digunakan oleh kelas `Vehicle` dan `Rental` untuk mencatat aktivitas yang terjadi selama pengelolaan kendaraan dan transaksi.

Dengan adanya pencatatan tersebut, aktivitas tertentu dapat ditelusuri kembali, misalnya ketika kendaraan mengalami perubahan status atau transaksi memasuki tahapan tertentu.

### 4. Enum

Program menggunakan tiga enum utama:

- `VehicleCategory`, untuk menentukan kategori kendaraan.
- `VehicleStatus`, untuk mengatur status kendaraan.
- `RentalStatus`, untuk mengatur status transaksi penyewaan.

Penggunaan enum membuat pilihan nilai status lebih terkontrol dibandingkan menggunakan teks bebas.

### 5. Null Safety

Null safety diterapkan pada atribut yang nilainya tidak selalu tersedia sejak awal.

Sebagai contoh, nomor telepon pelanggan dapat dikosongkan jika tidak tersedia. Catatan pengambilan dan laporan pengembalian juga belum tersedia sebelum proses terkait dilakukan.

Pendekatan ini membantu membedakan data yang memang belum ada dari data yang wajib diisi.

### 6. Custom Exception

Kelas `RentalRuleException` digunakan untuk menangani pelanggaran aturan bisnis dalam sistem.

Contohnya adalah ketika periode penyewaan tidak valid, SIM tidak memenuhi persyaratan, atau kendaraan tidak dapat dipesan karena jadwal maupun statusnya.

Dengan exception khusus, kesalahan yang berkaitan dengan aturan rental dapat dibedakan dari kesalahan teknis lainnya.

## Aturan Bisnis

Untuk menjaga agar proses penyewaan berjalan sesuai ketentuan, program menerapkan beberapa aturan berikut:

1. Satu kendaraan tidak boleh digunakan oleh dua transaksi penyewaan pada periode yang saling bertabrakan.
2. Tanggal pengembalian dapat menjadi tanggal mulai penyewaan berikutnya.
3. SIM pelanggan harus masih berlaku sesuai ketentuan periode penyewaan.
4. Kendaraan yang sedang dalam perawatan tidak dapat dipesan.
5. Nomor plat harus memenuhi format yang ditentukan dan tarif sewa harian harus lebih dari nol.
6. Lama penyewaan dibatasi antara 1 sampai 30 hari.
7. Pengambilan kendaraan hanya dapat dilakukan dalam periode penyewaan.
8. Nilai odometer dan waktu harus mengikuti urutan yang valid.
9. Biaya kerusakan harus disertai keterangan.
10. Transaksi yang sedang berjalan tidak dapat dibatalkan, sedangkan transaksi yang sudah selesai atau dibatalkan tidak dapat diubah kembali.
11. Denda keterlambatan dihitung berdasarkan hari kalender dengan tarif 150% dari tarif sewa harian untuk setiap hari keterlambatan, kemudian diperhitungkan terhadap deposit sesuai implementasi program.

Aturan-aturan tersebut digunakan untuk membatasi kondisi yang tidak diperbolehkan dalam proses penyewaan.

## Pengujian Program

Pengujian dilakukan melalui skenario yang dijalankan pada `bin/main.dart`.

Skenario tersebut digunakan untuk memperlihatkan proses penyewaan normal maupun kondisi ketika suatu aturan bisnis dilanggar.

Beberapa kondisi yang diperiksa meliputi:

- Reservasi kendaraan.
- Bentrokan jadwal penyewaan.
- Pemeriksaan masa berlaku SIM.
- Kendaraan yang sedang dalam perawatan.
- Pembatalan reservasi.
- Pengambilan dan pengembalian kendaraan.
- Perhitungan denda keterlambatan dan biaya kerusakan.
- Pencatatan aktivitas.
- Penanganan pelanggaran aturan melalui custom exception.

Selain menjalankan simulasi, pemeriksaan kode dilakukan menggunakan `dart analyze` untuk memastikan kode dapat dianalisis oleh Dart SDK.

## Tujuan Proyek

Proyek Patra Rent dibuat untuk menerapkan konsep Object-Oriented Programming (OOP) menggunakan bahasa Dart.

Melalui proyek ini, diharapkan dapat dipahami bagaimana konsep class dan object, composition, mixin, enum, null safety, serta custom exception diterapkan dalam sebuah program. Setiap konsep digunakan sesuai kebutuhan sistem agar kode lebih terstruktur dan mudah dipahami.

Selain itu, proyek ini bertujuan untuk membuat simulasi proses penyewaan mobil yang mencakup pengelolaan kendaraan, data pelanggan, reservasi, pengambilan, dan pengembalian kendaraan. Penerapan aturan bisnis dalam program juga diharapkan dapat membantu memahami bagaimana validasi dan penanganan kesalahan dilakukan untuk menjaga agar proses penyewaan berjalan sesuai ketentuan.