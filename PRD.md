# Product Requirements Document
## SiagaTani: Asisten Prediksi Risiko Hama & Penyakit Cabai

**Versi:** 3.0.0 (Draft)
**Tanggal:** 2026-09-23
**Basis:** Mode C: kondisi kode pada branch `main` (commit `d4d8269`)
**Platform:** Android & iOS (Flutter), tanpa backend kustom (Firebase sebagai layer server-side)
**Pengguna dokumen:** tim internal proyek & dosen pembimbing mata kuliah "Komputer dan Masyarakat"

> Setiap persyaratan diberi **status** hasil verifikasi terhadap kode, beserta rujukan file. Setiap angka target diberi **dasar**. Lihat Bagian 0.
>
> Konteks: proyek mata kuliah, fokus akademik pada penyempurnaan **akurasi & relevansi** untuk kondisi nyata, bukan target jumlah pengguna terdaftar (keputusan produk yang sudah dikonfirmasi sebelumnya).

---

## 0. Cara Membaca Dokumen Ini

### 0.1 Legenda Status

| Status | Arti |
|---|---|
| ✅ Implemented | Ada di kode dan berfungsi sesuai deskripsi (diverifikasi dengan membaca kode; belum tentu diuji di perangkat) |
| 🟡 Partial | Ada sebagian; celahnya dijelaskan di bawahnya |
| ⬜ Planned | Belum ada di kode; masuk roadmap |
| 🐞 Defect | Ada di kode tetapi perilakunya salah; lihat Bagian 5.3 |

### 0.2 Legenda Dasar Angka

| Dasar | Arti |
|---|---|
| **Kode** | Nilai literal di kode saat ini |
| **Standar** | Rujukan resmi eksternal (Lampiran A) |
| **Usulan** | Ditetapkan penulis; belum terukur, perlu disetujui tim |
| **TBD** | Belum ada dasar; masuk Pertanyaan Terbuka |

---

## 1. Executive Summary

### 1.1 Problem Statement
Petani cabai skala kecil sulit mendeteksi dini risiko serangan hama dan penyakit di lahan mereka karena keterbatasan akses ke penyuluh pertanian, dan tidak ada alat yang menggabungkan kondisi cuaca real-time dengan profil spesifik lahan (fase tanam, varietas, riwayat hama, lingkungan sekitar) untuk memberi peringatan yang *actionable*.

### 1.2 Proposed Solution
Aplikasi mobile (Flutter) yang meminta petani mengisi profil lahan satu kali (kuesioner bertahap + penempatan lokasi di peta), lalu menggabungkannya dengan data cuaca real-time untuk menjalankan mesin prediksi risiko berbasis aturan (*rule-based*) terhadap 5 hama/penyakit utama cabai. Hasilnya ditampilkan di layar detail lahan bersama saran aksi harian dalam bahasa alami via Gemini AI, berperan sebagai "penyuluh virtual".

### 1.3 Success Criteria (KPI)

| ID | KPI | Target | Dasar | Cara verifikasi |
|---|---|---|---|---|
| K1 | Kelengkapan alur inti (login → isi kuesioner → simpan lokasi → prediksi risiko tampil → saran AI tampil → lihat daftar lahan → update fase tanam) | 7/7 langkah berhasil tanpa exception runtime | **Usulan** | Checklist QA manual, dijalankan end-to-end di device fisik; belum ada laporan hasil |
| K2 | Validasi bobot rule engine (5 strategi hama di `PredictionService`, lihat Lampiran B) | ≥ 4 dari 5 strategi (80%) punya catatan sumber/validasi tertulis | **Usulan** | Dokumentasi tinjauan per strategi: bandingkan bobot skor dengan ≥1 sumber agronomi tertulis atau masukan ahli; belum dilakukan |
| K3 | Relevansi & keakuratan saran AI (Gemini) | ≥ 80% skenario dinilai relevan & akurat oleh reviewer manusia | **Usulan** | Review manual berpasangan pada 10-15 skenario uji (lihat §3.3); belum ada eval set |
| K4 | Waktu respons analisis risiko | ≤ 5 detik (di luar *cold-start* pertama Gemini) | **Usulan** (ambang UX umum, belum diturunkan dari pengukuran) | Waktu dari `FarmDetailScreen` dibuka sampai prediksi **dan** saran AI tampil penuh, diukur 10x di koneksi 4G stabil; belum diukur |
| K5 | Stabilitas sesi (*crash-free*) | ≥ 95% sesi tanpa crash/exception fatal dari minimal 20 sesi uji | **Usulan** | Observasi manual selama pengujian manual; belum ada laporan hasil |
| K6 | Cakupan hama vs. kebutuhan nyata (5 hama: Thrips, Lalat Buah, Antraknosa, Ulat Grayak, Kutu Kebul) | Merepresentasikan ancaman utama cabai di lokasi target | **TBD** | Studi literatur/wawancara informal; belum dilakukan |

**Eksplisit bukan tujuan/KPI saat ini**: jumlah petani terdaftar, retensi pengguna, atau metrik adopsi/pertumbuhan lainnya (keputusan produk dikonfirmasi tim).

---

## 2. User Experience & Functionality

### 2.1 Persona

| Persona | Deskripsi | Kebutuhan utama |
|---|---|---|
| **P1 Petani cabai** | Pengelola lahan cabai skala kecil (varietas rawit/keriting/besar), literasi digital menengah-rendah (tercermin dari UI kuesioner berbasis gambar/pilihan, bukan input teks bebas) | Saran singkat, praktis, dalam bahasa sehari-hari; input data minim mengetik |
| **P2 AI "penyuluh virtual"** | Bukan persona manusia; komponen produk (Gemini), bukan aktor dengan akun/peran tersendiri | Menyediakan saran aksi harian berbasis konteks cuaca + risiko |

Peran penyuluh pertanian manusia **belum** diakomodasi sebagai persona/pengguna terpisah di aplikasi (lihat Non-Goals).

### 2.2 User Stories & Acceptance Criteria

**US-01 Registrasi & Login**: ✅ Implemented (`lib/controllers/auth_controller.dart`, `lib/view/login_screen.dart`, `lib/view/register_screen.dart`)
*Sebagai petani, saya ingin mendaftar/masuk (email-password atau Google) agar data lahan saya tersimpan dan terikat ke akun saya.*
- Login gagal menampilkan pesan tetap "Login gagal. Cek email/password Anda." (`auth_controller.dart:57`)
- Registrasi berhasil memicu pesan sukses berisi nama pengguna (`auth_controller.dart:42`)
- Google Sign-In memakai `google_sign_in` dan `GoogleAuthProvider.credential` (`auth_controller.dart:64-87`)
- 🐞 Lihat D-01 (pesan error registrasi tidak konsisten dengan login).

**US-02 Mengisi Profil Lahan**: ✅ Implemented (`lib/view/question.dart`, `lib/controllers/farm_controller.dart`)
*Sebagai petani baru, saya ingin mengisi profil lahan (fase tanaman, pola tanam, varietas, riwayat hama, jenis mulsa, waktu semprot terakhir, lokasi via peta, tanaman di sekitar, nama lahan) dalam alur bertahap tanpa mengetik banyak.*
- Tombol "lanjut" nonaktif selama field wajib pada step aktif kosong (`isEnabled` di `question.dart:469-477`)
- Lokasi lahan dipilih lewat peta (`flutter_map`) sebelum lahan dapat disimpan
- 🐞 Lihat D-07 (peta ditampilkan tanpa atribusi OpenStreetMap).

**US-03 Melihat Skor Risiko Hama**: ✅ Implemented (`lib/data/services/prediction_service.dart`, `lib/controllers/prediction_controller.dart`)
*Sebagai petani, saya ingin melihat skor risiko per hama/penyakit (RENDAH/SEDANG/TINGGI/BAHAYA, alasan singkat & detail) untuk lahan saya berdasarkan kondisi cuaca terkini.*
- Risiko hanya ditampilkan bila skor > 0.40 (`prediction_service.dart:294`); level dipetakan >0.7 = BAHAYA, >0.5 = TINGGI, >0.3 = SEDANG (`prediction_service.dart:320-324`)
- Jika `lastPesticideTime` mengandung "< 3 hari", skor dipotong menjadi 20% dari nilai asli (`prediction_service.dart:284-292`)
- Setiap hasil disertai `detailedAnalysis` dan `preventionSteps` (lihat masing-masing strategi di `prediction_service.dart`)
- ⚠️ **Ambang tampil (0.40) dan faktor potongan pasca-semprot (×0.2) belum divalidasi terhadap sumber agronomi**, lihat K2 dan Pertanyaan Terbuka.

**US-04 Menerima Saran Aksi AI**: ✅ Implemented (`lib/data/services/ai_service.dart`, `lib/widgets/ai_insight_card.dart`)
*Sebagai petani, saya ingin menerima 1 paragraf saran aksi praktis dari AI yang mempertimbangkan cuaca, fase tanaman, dan risiko tertinggi hari ini.*
- Prompt mengirim kondisi cuaca, profil lahan, dan daftar `PredictionResult` sebagai konteks (`ai_service.dart:20-42`)
- Jika panggilan Gemini gagal (jaringan/kunci kosong), tampil teks fallback "Gagal terhubung dengan asisten AI. Pastikan koneksi internet tersedia." (`ai_service.dart:48-51`)
- ⚠️ **Prompt tidak melarang model menyebut dosis/bahan aktif di luar `preventionSteps` rule engine** (`ai_service.dart:27-42`), risiko halusinasi belum dimitigasi, lihat §3.2 dan K3.
- 🐞 Lihat D-05 (kunci API Gemini ikut ter-bundle di aplikasi client).

**US-05 Melihat Cuaca & Lokasi di Dashboard**: ✅ Implemented (`lib/data/services/weather_service.dart`, `lib/view/dashboard_screen.dart`, `lib/widgets/weather_card.dart`)
*Sebagai petani, saya ingin melihat cuaca & lokasi saat ini di dashboard tanpa perlu keluar aplikasi.*
- Data diambil dari OpenWeatherMap berdasarkan koordinat GPS (`weather_service.dart:12-35`)
- Jika kunci API kosong, memunculkan exception eksplisit "API Key kosong. Cek .env!" (`weather_service.dart:12`) alih-alih tampilan fallback ramah pengguna.
- ⚠️ **Belum ada mode offline/cache**, kegagalan jaringan/API membuat kartu cuaca tidak tampil (lihat Non-Goals dan D-05 terkait kunci sama).

**US-06 Membaca Info/Tips Pertanian ("Pojok Tani")**: 🟡 Partial (`lib/view/education_screen.dart`)
*Sebagai petani, saya ingin membaca info/tips pertanian (harga pasar, hama, tips budidaya) di satu tempat.*
- Daftar artikel tampil dengan gambar dan tautan eksternal (`education_screen.dart:8-40`)
- ⚠️ **Celah:** konten `articles` **hardcoded** di kode, bukan data dinamis dari backend/CMS (`education_screen.dart:8`); ini sesuai Non-Goals fase ini, dicatat di sini agar tidak dianggap fitur konten dinamis.
- 🐞 Lihat D-06 (satu tautan artikel mengarah ke `https://example.com`, bukan artikel sungguhan).

**US-07 Mengelola Daftar Lahan (dari `MyFarmScreen`)**: ✅ Implemented (`lib/view/my_farm_screen.dart`, `lib/data/services/firestore_service.dart`)
*Sebagai petani dengan banyak lahan, saya ingin melihat daftar semua lahan saya, membuka detailnya, serta mengubah fase tanam / nama / menghapus lahan dari daftar.*
- `updateFarmName`, `updateFarmPhase`, `deleteFarm` dipanggil dan tersimpan ke Firestore, tercermin langsung di UI via `snapshots()` (`firestore_service.dart:26-43`, dipanggil dari `my_farm_screen.dart:342-535`)
- Daftar lahan difilter per `userId` pemilik (`firestore_service.dart:52-53`)

**US-08 Mengelola Foto & Data Lahan dari Layar Detail (`FarmDetailScreen`)**: 🟡 Partial (`lib/view/farm_detail_screen.dart`)
*Sebagai petani, saya ingin mengubah foto, mengedit data, menghapus lahan, atau memperbarui fase tanam langsung dari layar detail lahan.*
- Menu popup "Ubah Foto", "Edit Lahan", "Hapus Lahan" tampil di `AppBar` (`farm_detail_screen.dart:68-131`)
- Tombol mengambang "Update Phase" tampil di layar (`farm_detail_screen.dart:194-200`)
- ⚠️ **Celah:** ketiga aksi menu popup hanya memanggil `ScaffoldMessenger` snackbar placeholder, tidak melakukan aksi nyata (`farm_detail_screen.dart:520-536`), meski fungsi setara (edit nama, hapus) **sudah berfungsi penuh** di US-07/`MyFarmScreen`.
- 🐞 Lihat D-02 (menu popup placeholder) dan D-03 (tombol "Update Phase" tidak melakukan apa pun).

### 2.3 Non-Goals
- **Tidak** membangun antarmuka/peran terpisah untuk penyuluh pertanian manusia (verifikasi, override saran AI, dashboard monitoring lintas-petani) pada fase ini.
- **Tidak** mendukung tanaman selain cabai (hanya 3 varietas cabai yang didukung kuesioner saat ini).
- **Tidak** menyediakan mode offline, aplikasi bergantung penuh pada Firestore, OpenWeatherMap, dan Gemini API yang butuh koneksi internet.
- **Tidak** membangun diagnosis hama berbasis foto/*computer vision*, tombol upload foto di `FarmDetailScreen` eksplisit berstatus placeholder ("Fitur Upload Foto akan segera hadir!"), meski field `imageUrl` sudah tersedia di `FarmModel` (`lib/data/models/farm_model.dart:26`).
- **Tidak** membangun sistem notifikasi/*alert push*, petani harus membuka aplikasi untuk melihat risiko terbaru.
- **Tidak** membangun backend/CMS untuk konten edukasi, daftar artikel di `EducationScreen` saat ini hardcoded (lihat US-06).
- **Tidak** menargetkan metrik adopsi (jumlah petani terdaftar, dsb.) sebagai ukuran sukses pada fase ini.

---

## 3. AI System Requirements

### 3.1 Komponen dan Peran

| Komponen | Peran | Rujukan |
|---|---|---|
| **Gemini 1.5 Flash** (`google_generative_ai` v0.4.7) | Menghasilkan 1 paragraf saran aksi berbahasa Indonesia dari konteks cuaca + profil lahan + hasil rule engine | `lib/data/services/ai_service.dart:9-13` |
| **Basis pengetahuan/protokol** | **Tidak ada**, model tidak dibatasi ke basis pengetahuan/protokol agronomi eksternal; hanya diberi hasil `PredictionResult` (termasuk `preventionSteps`) sebagai konteks dalam prompt | `ai_service.dart:20-42` |
| **Fallback non-AI** | Teks statis bila panggilan gagal (exception) atau respons kosong | `ai_service.dart:47` (respons kosong), `ai_service.dart:50` (exception) |

### 3.2 Aturan Keputusan
- Prompt meminta maksimal 3 kalimat, tanpa format Markdown, memprioritaskan risiko tertinggi bila ada (`ai_service.dart:38-41`).
- Konteks yang dikirim ke model: kondisi cuaca (`WeatherModel`), profil lahan (`FarmModel`), dan daftar `PredictionResult` dari rule engine (`ai_service.dart:20-33`).
- ⬜ **Belum ada** larangan eksplisit di prompt terhadap model menyebut nama produk/dosis/bahan aktif yang tidak ada di `preventionSteps`. Ini gap keputusan produk, bukan hanya teknis, karena rekomendasi dosis pestisida yang salah berdampak langsung ke praktik lahan nyata. Diusulkan masuk v1.1 (lihat R-02).

### 3.3 Strategi Evaluasi

| Uji | Metode | Target | Dasar |
|---|---|---|---|
| Ketepatan bobot rule engine | Susun 10-15 skenario cuaca × fase tanaman × riwayat hama, bandingkan skor & rekomendasi dengan literatur pertanian atau masukan penyuluh/ahli sungguhan | ≥ 4/5 strategi tervalidasi (K2) | Usulan |
| Kepatuhan saran AI ke basis rule engine | Untuk skenario yang sama, cek apakah dosis/bahan aktif yang disebut Gemini konsisten dengan `preventionSteps`, tidak berhalusinasi | ≥ 80% skenario relevan & tidak menyesatkan (K3) | Usulan |
| Jalur fallback | Paksa `GOOGLE_GEMINI_API_KEY` kosong dan jaringan terputus, verifikasi teks fallback tampil (`ai_service.dart:47`, `:50`) | 100% menampilkan fallback, tidak crash | Usulan |
| Latensi | Ukur waktu dari layar dibuka sampai saran AI tampil penuh | Lihat K4 | Usulan |

---

## 4. Technical Specifications

### 4.1 Arsitektur

```
FarmModel (Firestore)  ─┐
WeatherModel (OpenWeatherMap) ─┼─> PredictionService.analyzeRisk()  ──> Kartu Risiko (FarmDetailScreen)
Pin sekitar (Firestore, radius <=1000m) ─┘        │ (rule-based, client-side, sinkron)
                                                    └──> AIService.generateSmartAdvice() ──> AiInsightCard
                                                          (async, panggilan Gemini)
```

| Lapisan | Teknologi | Peran |
|---|---|---|
| Mobile | Flutter, state management GetX (`get` v4.7.2) | UI + seluruh logika bisnis (rule engine, orkestrasi API) |
| Backend | Tidak ada backend kustom | tidak berlaku |
| Data | Firebase Auth + Cloud Firestore (`farms`, `surrounding_pins`) | Satu-satunya layanan server-side; penyimpanan profil lahan dan pin sekitar |

Struktur folder (hasil refactor terbaru dari origin): `lib/data/models/`, `lib/data/services/`, `lib/core/theme/`, `lib/core/constants/`, `lib/core/utils/`, `lib/controllers/` (GetX: `AuthController`, `DashboardController`, `FarmController`, `MapSetupController`, `PredictionController`), `lib/view/` (layar penuh), `lib/widgets/` (`farm_overview_card.dart`, `phase_timeline.dart`, `weather_card.dart`, `ai_insight_card.dart`).

### 4.2 Titik Integrasi

| Integrasi | Dipakai oleh | Catatan |
|---|---|---|
| Firebase Auth | US-01 | Email/password + Google Sign-In |
| Cloud Firestore (`farms`) | US-02, US-03, US-07, US-08 | Difilter per `userId` (`firestore_service.dart:52-53`) |
| Cloud Firestore (`surrounding_pins`) | US-02, US-03 | 🐞 **Tidak difilter per user** (D-04) |
| OpenWeatherMap API | US-05 | Kunci di client-side `.env`; kuota/tier akun TBD; gagal tanpa fallback offline |
| Google Generative AI (Gemini 1.5 Flash) | US-04 | Kunci di client-side `.env`; kuota/tier akun TBD |
| OpenStreetMap tiles (`flutter_map`) | US-02, US-03, US-07 | Tile server publik; 🐞 atribusi wajib belum ditampilkan (D-07) |
| Geolocator / Geocoding | US-02, US-05 | Ambil posisi GPS device & reverse-geocode alamat |

### 4.3 Keamanan & Privasi

Data lahan menyimpan koordinat GPS presisi tinggi milik petani; belum ada kebijakan retensi/penghapusan data tertulis.

| Persyaratan | Status | Catatan |
|---|---|---|
| Autentikasi endpoint | ✅ Implemented | Ditangani Firebase Auth SDK; tidak ada endpoint kustom |
| Kredensial tidak ikut terbundel di aplikasi | 🐞 Defect | `GOOGLE_GEMINI_API_KEY` dan `OPENWEATHER_API_KEY` dimuat dari `.env` yang di-bundle sebagai asset (`pubspec.yaml`). File `.env` sendiri **tidak** masuk git (ada di `.gitignore`), tetapi ikut ter-*compile* ke dalam APK/IPA sehingga dapat diekstrak dari hasil build. Lihat D-05. |
| Validasi sertifikat TLS | ✅ Implemented | Tidak ditemukan `badCertificateCallback`/`HttpOverrides` yang menonaktifkan validasi TLS di `lib/`, memakai default Dart/Flutter HTTP client |
| Persetujuan data lokasi/pribadi | 🟡 Partial | Hanya permintaan izin GPS standar OS (Android/iOS); tidak ada layar kebijakan privasi/consent eksplisit di dalam aplikasi |
| Atribusi sumber data | 🐞 Defect | Tidak ditemukan widget atribusi OpenStreetMap di ketiga pemakai `FlutterMap` (`question.dart`, `my_farm_screen.dart`, `farm_detail_screen.dart`). Lihat D-07 |

---

## 5. Risks, Defects & Roadmap

### 5.1 Fase Rilis

| Fase | Isi | Status |
|---|---|---|
| **MVP** | US-01 s.d. US-08 (kondisi saat ini) | Sebagian besar Implemented, 2 story Partial |
| **v1.1** | R-01 s.d. R-05 | Planned |
| **v2.0** | Multi-tanaman, notifikasi push, mode offline, peran penyuluh manusia, konten edukasi dinamis, diagnosis foto berbasis *computer vision* | Planned, di luar scope akademik saat ini |

### 5.2 Persyaratan Prioritas v1.1

| ID | Persyaratan | Kriteria selesai |
|---|---|---|
| **R-01** | Validasi & kalibrasi ulang bobot skor rule engine dengan sumber/*expert review* | K2 tercapai (≥ 4/5 strategi punya catatan sumber) |
| **R-02** | Tambahkan larangan eksplisit di prompt Gemini agar tidak menyebut dosis/bahan aktif di luar `preventionSteps`, plus bangun eval set kecil | K3 tercapai (≥ 80% skenario relevan & tidak menyesatkan) |
| **R-03** | Pindahkan `GOOGLE_GEMINI_API_KEY` dan `OPENWEATHER_API_KEY` ke layer backend (Cloud Function) agar tidak ter-bundle di client | D-05 tertutup; kunci tidak lagi ditemukan di hasil `flutter build` |
| **R-04** | Tinjau dan terapkan *scoping* `userId` pada koleksi `surrounding_pins`, atau dokumentasikan keputusan produk bahwa data ini memang dibagikan lintas-petani | D-04 tertutup atau didokumentasikan sebagai keputusan sadar |
| **R-05** | Samakan status fitur Edit/Hapus/Upload Foto/Update Phase di `FarmDetailScreen` dengan `MyFarmScreen` (selesaikan aksinya, atau sembunyikan tombol placeholder) | D-02 dan D-03 tertutup |

### 5.3 Cacat Diketahui

| ID | Cacat | Dampak | Rujukan |
|---|---|---|---|
| **D-01** 🐞 | Registrasi menampilkan pesan error mentah `e.toString()` (sering berbahasa Inggris, format teknis Firebase), sedangkan login menampilkan teks Indonesia tetap | Pengguna dengan literasi digital menengah-rendah (P1) bisa bingung membaca pesan error registrasi | `lib/controllers/auth_controller.dart:44` |
| **D-02** 🐞 | Menu popup "Ubah Foto", "Edit Lahan", "Hapus Lahan" di `FarmDetailScreen` hanya menampilkan snackbar placeholder, tidak melakukan aksi nyata | Pengguna mengira fitur tersedia padahal tidak berfungsi; inkonsisten dengan `MyFarmScreen` yang fungsinya sama tapi nyata | `lib/view/farm_detail_screen.dart:520-536` |
| **D-03** 🐞 | Tombol mengambang "Update Phase" di `FarmDetailScreen` memiliki `onPressed: () {}` kosong | Tombol terlihat aktif tapi tidak melakukan apa pun; pengguna tidak dapat memperbarui fase tanam dari layar ini | `lib/view/farm_detail_screen.dart:197` |
| **D-04** 🐞 | Koleksi Firestore `surrounding_pins` tidak difilter per `userId` (`getAllPins`/`getPinsStream` mengambil semua dokumen) | Data lokasi tanaman sekitar milik satu petani dapat dibaca oleh semua pengguna lain, potensi celah privasi | `lib/data/services/firestore_service.dart:72-85` |
| **D-05** 🐞 | Kunci API Gemini & OpenWeatherMap dibundel dalam aplikasi client via `.env` sebagai asset (bukan di belakang backend) | Kunci dapat diekstrak dari hasil build APK/IPA, berisiko disalahgunakan (kuota habis/biaya tak terduga) | `pubspec.yaml` (assets), `lib/data/services/ai_service.dart:9`, `lib/data/services/weather_service.dart:8` |
| **D-06** 🐞 | Satu artikel di `EducationScreen` memiliki `url` placeholder `https://example.com`, bukan tautan artikel sungguhan | Pengguna yang menekan artikel tersebut diarahkan ke halaman tidak relevan | `lib/view/education_screen.dart:38` |
| **D-07** 🐞 | Peta OpenStreetMap (`flutter_map`) ditampilkan di 3 layar tanpa atribusi wajib sesuai [OSM Tile Usage Policy](https://operations.osmfoundation.org/policies/tiles/) | Potensi pelanggaran kebijakan penggunaan tile OSM (bukan hanya UX) | `lib/view/question.dart`, `lib/view/my_farm_screen.dart`, `lib/view/farm_detail_screen.dart:459-492` |

### 5.4 Strategi Pengujian
- **Kondisi saat ini**: `test/widget_test.dart` hanya berisi `main()` kosong dengan komentar TODO. **Tidak ada satu pun tes otomatis** yang berjalan di repo ini.
- Prioritas seam pengujian untuk v1.1: uji unit `PredictionService.analyzeRisk()` per strategi hama (seam tertinggi yang tidak butuh Firebase/jaringan). Masukan `FarmModel`+`WeatherModel` sintetis, verifikasi `percentage` dan `riskLevel` sesuai kombinasi kondisi (lihat Lampiran B untuk nilai konstanta).
- Uji `AIService.generateSmartAdvice()` di seam jaringan: mock respons Gemini gagal (exception) dan verifikasi fallback teks statis muncul (`ai_service.dart:50`), tanpa perlu memanggil API sungguhan.
- Tidak ada contoh tes yang sudah ada di repo untuk dijadikan acuan pola.

### 5.5 Risiko Teknis

| Risiko | Kemungkinan | Dampak | Mitigasi |
|---|---|---|---|
| Akurasi rule engine tidak tervalidasi (bobot skor ditulis manual tanpa referensi tercatat) | Tinggi | Rasa aman/khawatir yang salah ke petani berdasarkan skor yang belum divalidasi | Belum ada; direncanakan R-01 |
| Halusinasi AI (saran Gemini tidak difilter terhadap `preventionSteps` sebelum ditampilkan) | Sedang | Saran dosis/bahan aktif keliru pada keputusan nyata di lahan | Belum ada; direncanakan R-02 |
| Ketergantungan 3 API pihak ketiga tanpa fallback offline (OpenWeatherMap, Gemini, tile OSM) | Sedang | Aplikasi gagal total (dashboard cuaca kosong, saran AI tidak muncul) jika salah satu down/kuota habis | Ada penanganan exception per servis (`weather_service.dart:12`, `ai_service.dart:48-51`), tetapi tidak ada cache/mode offline |
| Eksposur kunci API di client build | Sedang | Kuota/biaya API disalahgunakan pihak lain | Belum ada; direncanakan R-03 |
| Nol cakupan tes otomatis | Tinggi | Regresi pada rule engine atau alur Firestore tidak terdeteksi sebelum demo/rilis | Belum ada; lihat §5.4 |

---

## 6. Pertanyaan Terbuka (perlu keputusan tim)

1. K1, K2, K3, K4, K5 (§1.3): semua bertanda **Usulan**, perlu dikonfirmasi/disesuaikan bersama pembimbing/tim sebelum dianggap target final, termasuk apakah 5 detik (K4) dan 95% *crash-free* dari 20 sesi (K5) adalah ambang yang realistis untuk pengujian akademik.
2. K6 (§1.3) dan cakupan 5 hama (§2.2 US-03, Lampiran B): **TBD**, belum ada studi lapangan/literatur untuk memastikan 5 hama yang dicakup (Thrips, Lalat Buah, Antraknosa, Ulat Grayak, Kutu Kebul) merepresentasikan ancaman utama cabai di lokasi target.
3. Ambang tampil skor risiko (>0.40) dan faktor potongan pasca-semprot (×0.2) (§2.2 US-03): apakah nilai ini aman digeneralisasi untuk semua jenis hama/pestisida, atau perlu disesuaikan per hama?
4. Kuota/tier akun OpenWeatherMap dan Google Generative AI (§4.2): **TBD**, perlu dicek di masing-masing dashboard akun sebelum demo/rilis, termasuk apakah tersedia anggaran untuk *upgrade tier* jika kuota gratis habis.
5. Keputusan produk untuk D-04 (§5.3): apakah koleksi `surrounding_pins` memang dimaksud dibagikan antar-petani (untuk deteksi inang hama bersama) atau harus di-*scope* privat per pengguna?
6. Kebijakan privasi/retensi data GPS & profil lahan (§4.3): belum ada dokumen tertulis; perlu diputuskan sebelum aplikasi dipakai di luar lingkup pengujian akademik.
7. Versi target untuk R-01 s.d. R-05 (§5.2) dan fitur v2.0 (§5.1): tim & tenggat waktu pengumpulan mata kuliah belum eksplisit, perlu diisi manual.

---

## Lampiran A: Rujukan Standar

Belum ada rujukan standar eksternal (jurnal agronomi, panduan resmi Kementerian Pertanian, dsb.) yang dikutip di dalam kode atau dokumentasi repo untuk memvalidasi bobot rule engine. Semua bobot skor di `PredictionService` (Lampiran B) saat ini berdasarkan penulisan manual pengembang, bukan sumber tertulis yang dapat dirujuk. Lihat K2 dan Pertanyaan Terbuka #1-#3.

## Lampiran B: Nilai Konstan Kode yang Dirujuk (Mode C)

| Nilai | Lokasi |
|---|---|
| Ambang tampil hasil prediksi: `percentage > 0.40` | `lib/data/services/prediction_service.dart:294` |
| Pemetaan level risiko: `>0.7` BAHAYA, `>0.5` TINGGI, `>0.3` SEDANG, sisanya RENDAH | `lib/data/services/prediction_service.dart:320-324` |
| Potongan skor pasca-semprot pestisida (`< 3 hari`): `× 0.2` | `lib/data/services/prediction_service.dart:284-292` |
| Clamp skor akhir ke rentang `0.0-0.99` | `lib/data/services/prediction_service.dart:309` |
| Thrips: skor dasar `0.3`, `+0.35` musim kemarau, `+0.2` inang sejenis di sekitar, `-0.25` mulsa perak + fase semai, `→0.1` bila hujan >15mm/24 jam | `lib/data/services/prediction_service.dart:22-68` |
| Lalat Buah: skor dasar `0.4` (hanya fase berbuah/panen), `+0.3` suhu 25-32°C, `+0.25` kelembapan >80% atau hujan, `+0.15` ada inang buah di sekitar, `→0.1` bila suhu <16°C | `lib/data/services/prediction_service.dart:72-128` |
| Antraknosa: skor dasar `0.15`, `+0.65` basah (>4 jam/hari atau kelembapan >85%) dan hangat (20-30°C), `+0.15` hujan >5mm, `→0.1` bila tidak basah | `lib/data/services/prediction_service.dart:131-177` |
| Ulat Grayak: skor dasar `0.2`, `+0.25` mulsa hitam, `+0.2` suhu <28°C, `-0.2` suhu >35°C | `lib/data/services/prediction_service.dart:180-216` |
| Kutu Kebul: skor dasar `0.2`, `+0.35` fase semai/vegetatif, `+0.3` suhu >30°C, `+0.15` ada inang Solanaceae/Cucurbitaceae di sekitar | `lib/data/services/prediction_service.dart:218-260` |
| Model AI: `gemini-1.5-flash` | `lib/data/services/ai_service.dart:13` |
| Dart SDK terkunci ke `^3.9.2` | `pubspec.yaml:8` |
| `flutter_native_splash` menonaktifkan splash untuk web (`web: false`) | `pubspec.yaml:32` |

---

*Dokumen ini dibuat dari pembacaan kode aktual pada commit `d4d8269` (2026-09-23), bukan dari asumsi atau README. Status "Implemented" berarti terlihat di kode, bukan berarti sudah diuji di perangkat fisik. Bagian yang ditandai TBD atau Usulan perlu diisi/disetujui bersama pembimbing atau tim internal, bukan diasumsikan sepihak oleh dokumen ini.*
