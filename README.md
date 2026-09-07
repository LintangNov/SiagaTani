# SiagaTani: Sistem Peringatan Dini & Rekomendasi Tani Berbasis AI

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-v3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=white)](https://firebase.google.com)
[![Gemini AI](https://img.shields.io/badge/Google_Gemini-1.5_Flash-4285F4?logo=googlegemini&logoColor=white)](https://ai.google.dev/)
[![Project Category](https://img.shields.io/badge/Mata_Kuliah-Komputer_dan_Masyarakat-4CAF50)](#)

**SiagaTani** adalah aplikasi mobile inovatif berbasis Flutter yang dirancang khusus untuk mendeteksi dini risiko serangan hama dan penyakit pada komoditas pertanian (fokus utama: tanaman cabai). Proyek ini dikembangkan sebagai **Proyek Akhir Mata Kuliah Komputer dan Masyarakat (Semester 3)**, dengan tujuan memberikan solusi teknologi tepat guna yang dapat membantu petani meningkatkan produktivitas hasil panen dan meminimalkan kegagalan budidaya melalui pengambilan keputusan cerdas.

## Latar Belakang & Pendekatan Solusi

Melalui wawancara langsung bersama Kelompok Wanita Tani (KWT) di Caturtunggal, Sleman, DI Yogyakarta, ditemukan bahwa penanganan organisme pengganggu tanaman (khususnya cabai) masih bersifat **reaktif**, tindakan baru diambil setelah tanaman terlanjur rusak dan hama menyebar luas. Di saat yang sama, akses edukasi proteksi tanaman menemui hambatan karena petani sangat bergantung pada ketersediaan Penyuluh Pertanian Lapangan (PPL), baik lewat kunjungan berkala maupun tanya jawab via pesan WhatsApp.

Untuk memutus pola tersebut, pendekatan penanganan digeser dari kuratif menjadi **pencegahan preventif**. Logika agronomi lapangan diotomatisasi melalui mesin kalkulasi risiko yang menimbang dinamika cuaca mikro, fase kerentanan komoditas, efektivitas mulsa, hingga residu pestisida. Informasi ini dipadukan dengan pemetaan spasial radius migrasi hama dari lahan tetangga, lalu dirangkum oleh model kecerdasan buatan generatif menjadi instruksi mitigasi praktis dengan gaya komunikasi layaknya seorang penyuluh pertanian.

Dari pendekatan ini lahir **SiagaTani**, sebuah asisten digital berbasis *mobile* yang memfasilitasi deteksi dini dan pendampingan budidaya secara mandiri, memungkinkan petani mengambil keputusan mitigasi terukur sebelum kegagalan panen terjadi.

---

## Fitur Utama

Aplikasi SiagaTani dilengkapi dengan modul-modul cerdas berikut:

1. **Dashboard Tani & Cuaca Real-time**  
   Menampilkan ringkasan kondisi lingkungan petani secara instan, termasuk integrasi API cuaca lokal (suhu, kelembapan, kecepatan angin, curah hujan) untuk memetakan iklim mikro di lahan Anda.
   
2. **Sistem Deteksi Risiko Hama Dinamis (Prediction Engine)**  
   Menganalisis potensi serangan 5 jenis hama/penyakit utama cabai secara real-time:
   * **Thrips (Daun Keriting)**
   * **Lalat Buah**
   * **Antraknosa (Patek)**
   * **Ulat Grayak**
   * **Kutu Kebul (Penyebab Virus Kuning)**  
   *Analisis dihitung menggunakan **Strategy Pattern** berdasarkan variabel cuaca, jenis mulsa, fase tumbuh tanaman, keberadaan tanaman inang di sekitar, dan riwayat penyemprotan.*

3. **Rekomendasi Cerdas AI (Smart Gemini Advice)**  
   Terintegrasi langsung dengan **Google Generative AI (Gemini 1.5 Flash)** yang menganalisis kombinasi data cuaca saat ini dan tingkat risiko hama untuk menghasilkan saran aksi mitigasi yang ringkas, santai, dan praktis (seperti arahan seorang Penyuluh Pertanian Lapangan).

4. **Pemetaan Lahan Interaktif & Analisis Reservoir Hama**  
   Menggunakan peta berbasis OpenStreetMap (`flutter_map`) untuk menandai koordinat presisi lahan utama dan memetakan vegetasi sekitar lahan (lahan tetangga) guna memantau tanaman inang lain yang berpotensi menyebarkan hama (migrasi hama).

5. **Pojok Tani (Pusat Edukasi)**  
   Akses artikel agribisnis, panduan pembuatan pestisida nabati secara mandiri, info pengendalian hama, hingga pembaruan harga pasar pangan secara berkala.

6. **Sinkronisasi Cloud & Manajemen Multi-Lahan**  
   Mendukung pendaftaran dan pengelolaan beberapa lahan sekaligus oleh satu akun dengan penyimpanan data terpusat di cloud Firebase.

---

## Arsitektur & Tech Stack

Aplikasi ini dibangun menggunakan arsitektur modular yang memisahkan tanggung jawab visual, logika bisnis, dan penyedia data (*Service/Repository*):

* **Framework Utama:** [Flutter (Dart SDK ^3.9.2)](https://flutter.dev)
* **Manajemen State & Dependensi:** [GetX](https://pub.dev/packages/get)
* **Backend & Autentikasi:** Firebase (Core, Auth, Firestore, Google Sign-in)
* **Kecerdasan Buatan:** Google Generative AI (Gemini API SDK)
* **Engine Peta:** Flutter Map (OpenStreetMap) & Geolocator
* **Data Cuaca:** OpenWeatherMap API
* **Desain UI:** Kustomisasi visual dengan [Google Fonts (Poppins)](https://pub.dev/packages/google_fonts) dan asset SVG (`flutter_svg`).

---

## Struktur Folder Project

Berikut adalah struktur folder dalam direktori `lib/` yang memisahkan kode berdasarkan arsitektur MVC yang rapi:

```text
lib/
├── [controllers/](./lib/controllers)
│   ├── [auth_controller.dart](./lib/controllers/auth_controller.dart)       # Alur login, register, dan Google Sign-In
│   ├── [dashboard_controller.dart](./lib/controllers/dashboard_controller.dart)  # Logika cuaca, GPS, dan pemanggilan AI
│   ├── [farm_controller.dart](./lib/controllers/farm_controller.dart)       # CRUD data lahan ke Firestore
│   ├── [map_setup_controller.dart](./lib/controllers/map_setup_controller.dart)  # Koordinat GPS lahan utama & pin sekitar
│   └── [prediction_controller.dart](./lib/controllers/prediction_controller.dart) # Kontroler kalkulasi risiko di detail lahan
│
├── [core/](./lib/core)
│   └── [theme/](./lib/core/theme)
│       └── [app_theme.dart](./lib/core/theme/app_theme.dart)         # Konfigurasi skema warna hijau pertanian & font
│
├── [data/](./lib/data)
│   ├── [models/](./lib/data/models)
│   │   ├── [farm_model.dart](./lib/data/models/farm_model.dart)         # Struktur data Lahan (jenis mulsa, fase, koordinat)
│   │   ├── [prediction_result.dart](./lib/data/models/prediction_result.dart)  # Struktur output analisis risiko hama
│   │   ├── [surrounding_pin_model.dart](./lib/data/models/surrounding_pin_model.dart) # Struktur data titik koordinat inang tetangga
│   │   └── [weather_model.dart](./lib/data/models/weather_model.dart)         # Struktur data respon cuaca OpenWeather
│   │
│   └── [services/](./lib/data/services)
│       ├── [ai_service.dart](./lib/data/services/ai_service.dart)         # Integrasi SDK Google Generative AI (Gemini 1.5)
│       ├── [firestore_service.dart](./lib/data/services/firestore_service.dart)  # CRUD API Firestore
│       ├── [prediction_service.dart](./lib/data/services/prediction_service.dart) # Engine kalkulator hama (Strategy Pattern)
│       └── [weather_service.dart](./lib/data/services/weather_service.dart)    # Integrasi API HTTP OpenWeatherMap
│
├── [view/](./lib/view)
│   ├── [dashboard_screen.dart](./lib/view/dashboard_screen.dart)    # Halaman beranda utama petani
│   ├── [education_screen.dart](./lib/view/education_screen.dart)    # Halaman Pojok Tani (Artikel Edukasi)
│   ├── [farm_detail_screen.dart](./lib/view/farm_detail_screen.dart)  # Halaman detail analisis risiko & peta lahan
│   ├── [my_farm_screen.dart](./lib/view/my_farm_screen.dart)      # Daftar lahan terdaftar milik user
│   ├── [question.dart](./lib/view/question.dart)              # Form kuesioner interaktif pembuatan lahan baru
│   └── ... (screen onboarding, auth, dan splash)
│
├── [widgets/](./lib/widgets)                      # Kumpulan komponen reusable UI (WeatherCard, Timeline, dll.)
│
├── [firebase_options.dart](./lib/firebase_options.dart)       # Konfigurasi platform Firebase auto-generated
└── [main.dart](./lib/main.dart)                           # Titik awal jalannya aplikasi (inisialisasi Firebase, Env, & GetX)
```

---

## Langkah Instalasi & Penggunaan

Ikuti langkah-langkah berikut untuk menjalankan proyek SiagaTani secara lokal pada perangkat Anda:

### 1. Prasyarat
* Pastikan Anda telah memasang [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi rekomendasi: `>=3.22.x` dengan Dart `^3.x.x`).
* Anda memerlukan emulator Android/iOS aktif atau perangkat fisik yang terhubung untuk pengujian.
* Koneksi internet aktif (untuk Firebase, OpenWeather, dan Google Gemini).

### 2. Kloning Repositori
```bash
git clone https://github.com/LintangNov/SiagaTani.git
cd SiagaTani
```

### 3. Konfigurasi File Lingkungan (`.env`)
Buat berkas bernama `.env` di direktori akar proyek (sejajar dengan `pubspec.yaml`), lalu isi dengan API Key Anda sendiri:

```env
OPENWEATHER_API_KEY="ISI_API_KEY_OPENWEATHER_ANDA"
GOOGLE_GEMINI_API_KEY="ISI_API_KEY_GEMINI_ANDA"
```
*Catatan: Pastikan `.env` terdaftar dalam aset di `pubspec.yaml` (sudah terdaftar secara bawaan).*

### 4. Setup Firebase
Aplikasi ini memerlukan Firebase Firestore & Autentikasi.
1. Buat proyek baru di [Firebase Console](https://console.firebase.google.com/).
2. Aktifkan **Google Sign-In** dan **Email/Password** di tab Authentication.
3. Aktifkan **Cloud Firestore Database** dalam mode uji atau produksi.
4. Jalankan perintah inisialisasi Firebase CLI di komputer Anda untuk mengkonfigurasi berkas `lib/firebase_options.dart`:
   ```bash
   flutterfire configure
   ```

### 5. Pasang Dependensi & Jalankan Aplikasi
Jalankan perintah berikut di terminal:
```bash
# Mengambil dependensi package pubspec
flutter pub get

# Jalankan aplikasi pada perangkat/emulator yang terhubung
flutter run
```

---

## Penjelasan Singkat Mesin Prediksi (Prediction Engine)

Sistem rekomendasi pencegahan hama di SiagaTani tidak hanya mengandalkan insting, melainkan kalkulasi objektif yang adaptif terhadap lingkungan. Menggunakan *design pattern* **Strategy**, berkas [`prediction_service.dart`](./lib/data/services/prediction_service.dart) menerapkan kalkulasi berikut:

* **Wash-out Effect (Curah Hujan Tinggi):** Hama seperti *Thrips* yang fisiknya kecil akan dikurangi persentasenya secara signifikan apabila curah hujan tinggi (>15mm/24 jam), karena populasinya terhanyut oleh air hujan secara mekanis.
* **Faktor Mulsa Perak (Refleksi UV):** Jika lahan menggunakan mulsa perak dan tanaman masih berada di fase bibit (*seedling*), risiko hama *Thrips* & *Kutu Kebul* diturunkan sebanyak 25% karena pantulan sinar UV mengacaukan navigasi penglihatan hama.
* **Fase Rentan Tanaman:** Lalat Buah hanya akan dihitung risikonya apabila tanaman memasuki fase pembuahan (*fruiting*) atau panen (*harvesting*). Pada fase vegetatif awal, risikonya adalah 0%.
* **Residu Perlindungan Pestisida:** Jika petani baru menyemprot pestisida kurang dari 3 hari yang lalu (`lastPesticideTime < 3 hari`), maka seluruh persentase risiko serangan diturunkan secara drastis (dikalikan `0.2`) karena proteksi pestisida masih aktif melindungi tanaman.

---

## 👥 Pengembang / Kontributor

Proyek ini disusun dan dirawat oleh kelompok mahasiswa Jurusan Teknologi Informasi/Ilmu Komputer sebagai syarat pemenuhan nilai tugas akhir mata kuliah **Komputer dan Masyarakat**:

* **Waladi Lintang Novianto** - ([@LintangNov](https://github.com/LintangNov))
* **Pande Made Deva Brahmasta** - ([@devabrahmasta](https://github.com/devabrahmasta))

