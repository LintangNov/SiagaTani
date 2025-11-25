import 'dart:math';
import '../models/weather_model.dart';

class DummyWeatherService {
  final Random _rng = Random();

  Future<WeatherModel> getCurrentWeather() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulasi loading

    // --- DAFTAR SKENARIO UNTUK PENGUJIAN ---
    List<WeatherModel> scenarios = [
      
      // 1. SKENARIO: "NERAKA" PESTISIDA (Panas & Kering)
      // Prediksi: Thrips & Kutu Kebul MELEDAK (Risiko Tinggi), Jamur Mati.
      WeatherModel(
        temperature: 34.5,      // Sangat Panas (>32°C)
        humidity: 45.0,         // Kering
        condition: "Cerah Terik", 
        season: "Musim Kemarau",
        windSpeed: 5.0,
        rainfall24h: 0.0,       // Tidak ada hujan
        maxTemp: 35.0,          // Heat stress boundary
        wetHours: 0,            // Daun kering total
      ),

      // 2. SKENARIO: "WASH-OUT" (Hujan Badai)
      // Prediksi: Thrips HILANG (Hanyut tercuci), Lalat Buah TURUN (Susah terbang), tapi Risiko JAMUR (Antraknosa) MUNCUL.
      WeatherModel(
        temperature: 24.0,      // Sejuk
        humidity: 96.0,         // Sangat Lembap
        condition: "Hujan Petir", 
        season: "Musim Hujan",
        windSpeed: 15.0,        // Angin kencang
        rainfall24h: 30.0,      // 30mm (Sangat lebat -> Wash-out Thrips)
        maxTemp: 25.0,
        wetHours: 10,           // Daun basah seharian -> Bahaya Antraknosa
      ),

      // 3. SKENARIO: "ZONA NYAMAN" HAMA (Hangat & Lembap)
      // Prediksi: Lalat Buah TINGGI (Suhu & Kelembapan ideal), Antraknosa SEDANG.
      WeatherModel(
        temperature: 28.5,      // Suhu kamar (Ideal metabolisme serangga)
        humidity: 82.0,         // Lembap tapi tidak hujan deras
        condition: "Berawan", 
        season: "Peralihan",
        windSpeed: 3.0,         // Angin tenang (Lalat bebas terbang)
        rainfall24h: 2.0,       // Hujan rintik (bikin lembap kulit buah)
        maxTemp: 30.0,
        wetHours: 4,
      ),

      // 4. SKENARIO: DINGIN EKSTREM (Di Pegunungan)
      // Prediksi: Hampir semua hama TERTIDUR (Risiko Rendah), kecuali penyakit tertentu.
      WeatherModel(
        temperature: 15.0,      // Dingin (<16°C lalat malas terbang)
        humidity: 70.0,
        condition: "Kabut", 
        season: "Musim Hujan",
        windSpeed: 8.0,
        rainfall24h: 5.0,
        maxTemp: 18.0,
        wetHours: 2,
      ),
    ];

    // Pilih satu skenario secara acak setiap kali fungsi dipanggil
    // Tips: Untuk mengganti skenario, cukup keluar masuk halaman Dashboard atau Restart aplikasi.
    var selectedScenario = scenarios[_rng.nextInt(scenarios.length)];
    
    print("DEBUG: Menggunakan Skenario Cuaca: ${selectedScenario.condition} | Temp: ${selectedScenario.temperature}");
    
    return selectedScenario;
  }
}