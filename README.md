# VanqisFresh Mobile

VanqisFresh Mobile adalah aplikasi berbasis Flutter yang dirancang sebagai platform mobile untuk sistem penjualan produk buah dan sayur. Aplikasi ini memungkinkan pengguna untuk melihat katalog produk, mengelola keranjang, serta melakukan proses checkout dan pembayaran langsung melalui perangkat Android.

Aplikasi dikembangkan dengan pendekatan mobile-first dan berfokus pada pengalaman pengguna yang ringan, cepat, dan responsif. Seluruh data terintegrasi dengan backend melalui REST API, sementara state lokal seperti keranjang dan autentikasi dikelola langsung di sisi client.

## Fungsionalitas

Aplikasi menangani interaksi utama pengguna, meliputi eksplorasi produk buah dan sayur, pengelolaan keranjang, checkout, serta upload bukti pembayaran.

## Teknologi

Aplikasi dikembangkan menggunakan:

- Flutter
- Riverpod
- Dio
- Go Router
- Shared Preferences
- Image Picker

## Instalasi

1. Clone repository dan masuk ke direktori project
   
   ```bash
   git clone https://github.com/RozhakDev/VanqisFresh_Mobile.git
   cd VanqisFresh_Mobile
   ```

2. Install dependency
   
   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi
   
   ```bash
   flutter run
   ```

## Struktur

Aplikasi menggunakan pendekatan Feature-First Clean Architecture untuk memisahkan fitur, state management, dan komunikasi API agar pengembangan lebih terstruktur dan mudah dipelihara.

## Catatan

Aplikasi mobile terintegrasi dengan backend melalui REST API dan dirancang khusus untuk platform Android. Beberapa data seperti keranjang dan autentikasi disimpan secara lokal untuk menjaga performa dan pengalaman pengguna tetap optimal.

## License

See [LICENSE](./LICENSE)