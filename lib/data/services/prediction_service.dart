import '../models/farm_model.dart';
import '../models/weather_model.dart';
import '../models/prediction_result.dart';

// ═══════════════════════════════════════════════════════════════
// Model risiko hama berbasis literatur ("virtual sensor").
//
// Setiap hama dihitung dari:
//   1. Kesesuaian suhu (kurva trapesium) dari rata-rata suhu 14 hari
//      terakhir, karena populasi serangga tumbuh dari kondisi yang menumpuk,
//      bukan dari suhu satu saat.
//   2. Akumulasi derajat-hari (degree-day) untuk menduga jumlah generasi.
//   3. Pengubah hujan, kelembapan, dan jam daun basah.
//   4. Faktor lahan: fase tanaman, inang di sekitar, mulsa, riwayat serangan.
//
// Angka ambang diambil dari jurnal (lihat komentar di tiap strategi).
// Bobot penjumlahan skor masih ditetapkan tim dan perlu dikalibrasi dengan
// laporan lapangan petani.
// ═══════════════════════════════════════════════════════════════

/// Kesesuaian suhu bentuk trapesium: 0 di luar [tMin, tMax], naik linear ke 1
/// pada [opt1, opt2], lalu turun linear ke 0 di [tMax].
double thermalSuitability(
  double t,
  double tMin,
  double opt1,
  double opt2,
  double tMax,
) {
  if (t <= tMin || t >= tMax) return 0;
  if (t < opt1) return (t - tMin) / (opt1 - tMin);
  if (t <= opt2) return 1;
  return (tMax - t) / (tMax - opt2);
}

/// Penampung skor + alasan, supaya setiap kenaikan skor punya penjelasan.
class _Score {
  _Score(this.value);

  double value;
  final List<(double, String)> _reasons = [];

  void add(double delta, String reason) {
    value += delta;
    _reasons.add((delta, reason));
  }

  /// Alasan diurutkan: penambah risiko terbesar dulu, lalu penurun.
  String bullets() {
    final ups = _reasons.where((r) => r.$1 > 0).toList()
      ..sort((a, b) => b.$1.compareTo(a.$1));
    final downs = _reasons.where((r) => r.$1 <= 0).toList()
      ..sort((a, b) => a.$1.compareTo(b.$1));
    return [...ups, ...downs].map((r) => '\n• ${r.$2}').join();
  }
}

String _c(double v) => v.toStringAsFixed(1);
String _mm(double v) => v.toStringAsFixed(0);

abstract class PestStrategy {
  PredictionResult? calculate(
    FarmModel farm,
    WeatherModel weather,
    List<String> nearbyPlants,
  );
}

bool _hadPestHistory(FarmModel farm) => farm.pestHistory == 'Pernah';

// ── Thrips (Thrips parvispinus) ─────────────────────────────────
// • Suhu optimum 28–31 °C dan RH 60–78%; suhu ekstrem 35 °C menekan populasi
//   (Ngosong et al., 2024, Environmental Entomology).
// • Hujan dan RH tinggi berkorelasi negatif (Mandal et al., 2023: hujan
//   ≥6 mm & RH ≥65% menekan; Rizwana et al., 2024: RH pagi r = −0,67).
// • Puncak populasi saat berbunga hingga awal berbuah (Sadafale et al., 2026;
//   Divya et al., 2025: serangan mulai bersamaan dengan pembungaan).
class ThripsStrategy implements PestStrategy {
  static const name = 'Thrips (Daun Keriting)';

  @override
  PredictionResult? calculate(
    FarmModel farm,
    WeatherModel weather,
    List<String> nearbyPlants,
  ) {
    if (weather.rainfall24h > 15.0) {
      return PredictionService.buildResult(
        name,
        0.1,
        'Populasi tercuci oleh hujan lebat.',
        'Hujan lebat dalam 24 jam terakhir (${_mm(weather.rainfall24h)} mm) menjatuhkan nimfa dan imago Thrips dari daun.',
        [
          'Lakukan pemantauan 2 hari setelah hujan reda.',
          'Fokuskan pengamatan pada pucuk daun muda dan bunga.',
        ],
      );
    }

    final t14 = weather.meanTemp(14);
    final rh7 = weather.meanHumidity(7);
    final rain7 = weather.rainTotal(7);
    final s = _Score(0.1);

    final thermal = thermalSuitability(t14, 15, 25, 31, 36);
    s.add(
      0.4 * thermal,
      thermal >= 0.7
          ? 'Suhu rata-rata 14 hari ${_c(t14)}°C berada di rentang optimum perkembangan Thrips (25–31°C).'
          : 'Suhu rata-rata 14 hari ${_c(t14)}°C kurang ideal bagi Thrips.',
    );

    if (rain7 < 20) {
      s.add(0.1, 'Hanya ${_mm(rain7)} mm hujan dalam 7 hari. Cuaca kering membuat Thrips tidak tercuci dari daun.');
    } else if (rain7 > 50) {
      s.add(-0.15, 'Hujan ${_mm(rain7)} mm dalam 7 hari ikut mencuci Thrips dari daun.');
    }

    if (rh7 <= 75) {
      s.add(0.05, 'Kelembapan rata-rata ${_mm(rh7)}% mendukung aktivitas Thrips.');
    } else if (rh7 >= 85) {
      s.add(-0.1, 'Kelembapan tinggi (${_mm(rh7)}%) menekan populasi Thrips.');
    }

    switch (farm.cropStage) {
      case CropStage.flowering:
      case CropStage.fruiting:
        s.add(0.2, 'Fase berbunga sampai awal berbuah adalah puncak serangan Thrips.');
      case CropStage.vegetative:
        s.add(0.05, 'Pucuk daun muda fase vegetatif mulai disukai Thrips.');
      default:
        break;
    }

    if (nearbyPlants.contains('Cabai Rawit')) {
      s.add(0.1, 'Ada tanaman cabai lain di sekitar yang bisa menjadi sumber perpindahan Thrips.');
    }
    if (_hadPestHistory(farm)) {
      s.add(0.05, 'Lahan pernah terserang hama, sehingga populasi awal mungkin sudah ada.');
    }
    if (farm.mulchType == MulchType.silver) {
      s.add(-0.15, 'Pantulan cahaya mulsa perak membingungkan Thrips saat mencari tanaman.');
    }

    return PredictionService.buildResult(
      name,
      s.value,
      thermal >= 0.7 && rain7 < 20
          ? 'Cuaca hangat dan kering memicu ledakan Thrips.'
          : 'Pantau pucuk dan bunga dari serangan Thrips.',
      'Analisis risiko Thrips berdasarkan cuaca 14 hari terakhir:${s.bullets()}',
      [
        'Rotasi Insektisida: Gunakan bahan aktif Abamectin (Gol. 6) selang-seling dengan Spinetoram (Gol. 5) untuk cegah resistensi.',
        'Mekanis: Pasang perangkap likat warna BIRU atau PUTIH (40 buah/ha).',
        'Hayati: Semprotkan jamur Beauveria bassiana pada sore hari.',
        'Sanitasi: Potong pucuk daun yang keriting parah dan bakar.',
      ],
    );
  }
}

// ── Lalat Buah (Bactrocera dorsalis) ────────────────────────────
// • Berkembang pada 15–33 °C; optimum pertumbuhan populasi 26–29 °C
//   (Dongmo et al., 2021; Choudhary et al., 2024).
// • Di kebun Indonesia, kelembapan berkorelasi positif sedangkan suhu dan
//   hujan tidak signifikan (Susanto et al., 2022). RH optimum 60–70%
//   (Pant et al., 2025).
// • Serangan meningkat pada fase generatif/berbuah, 5–9 MST
//   (Holis et al., 2023; Agustini et al., 2023).
class FruitFlyStrategy implements PestStrategy {
  static const name = 'Lalat Buah';

  @override
  PredictionResult? calculate(
    FarmModel farm,
    WeatherModel weather,
    List<String> nearbyPlants,
  ) {
    if (farm.cropStage != CropStage.fruiting &&
        farm.cropStage != CropStage.harvesting) {
      return null;
    }

    final t14 = weather.meanTemp(14);
    if (t14 < 15) {
      return PredictionService.buildResult(
        name,
        0.1,
        'Suhu dingin menghambat aktivitas lalat buah.',
        'Suhu rata-rata ${_c(t14)}°C berada di bawah batas perkembangan lalat buah (15°C).',
        ['Pantau perangkap secara rutin.'],
      );
    }

    final rh7 = weather.meanHumidity(7);
    final s = _Score(0.15);
    s.add(0.15, 'Buah cabai yang terbentuk menjadi tempat lalat buah bertelur.');

    final thermal = thermalSuitability(t14, 15, 26, 29, 33);
    s.add(
      0.35 * thermal,
      thermal >= 0.7
          ? 'Suhu rata-rata ${_c(t14)}°C mendekati suhu optimum lalat buah berkembang biak (26–29°C).'
          : 'Suhu rata-rata ${_c(t14)}°C kurang ideal bagi lalat buah.',
    );

    if (rh7 >= 70) {
      s.add(0.1, 'Kelembapan ${_mm(rh7)}% mendukung kelimpahan lalat buah dan melunakkan kulit buah.');
    }

    final bool hasFruitHost = nearbyPlants.any(
      (p) => ['Mangga', 'Jambu', 'Jeruk', 'Pepaya', 'Pisang', 'Nangka', 'Terong', 'Mentimun']
          .contains(p),
    );
    if (hasFruitHost) {
      s.add(0.15, 'Tanaman buah di sekitar lahan menjadi sumber lalat buah.');
    }
    if (_hadPestHistory(farm)) {
      s.add(0.05, 'Lahan pernah terserang hama, sehingga populasi awal mungkin sudah ada.');
    }

    return PredictionService.buildResult(
      name,
      s.value,
      'Fase berbuah dan suhu hangat meningkatkan risiko.',
      'Lalat buah menjadi ancaman karena:${s.bullets()}',
      [
        'Perangkap Jantan: Pasang atraktan Metil Eugenol (Petrogenol) sebanyak 20-24 titik/ha.',
        'Umpan Protein: Semprotkan umpan protein untuk menarik lalat betina.',
        'Sanitasi Ketat: Kubur buah jatuh sedalam 50cm untuk memutus siklus larva.',
        'Kultur Teknis: Pembungkusan buah (brongsong) jika populasi sangat tinggi.',
      ],
    );
  }
}

// ── Antraknosa / Patek (Colletotrichum spp.) ────────────────────
// • Infeksi ditentukan gabungan suhu dan lama daun basah; makin dekat suhu
//   optimum, makin singkat waktu basah yang dibutuhkan (Kang et al., 2010,
//   model logistik untuk cabai).
// • Kisaran suhu optimum infeksi Colletotrichum ±25–30 °C (Salotti et al.,
//   2022); ±27 °C dengan RH 80% memicu infeksi (Tiwari et al., 2024).
// • Spora menyebar lewat percikan air hujan (Kang et al., 2010; Tasrif
//   et al., 2024); serangan berat pada musim hujan (Hodiyah et al., 2024).
// • Jamur bertahan lama di sisa tanaman sebagai sumber inokulum
//   (Harisi et al., 2023).
class AnthracnoseStrategy implements PestStrategy {
  static const name = 'Antraknosa (Patek)';

  @override
  PredictionResult? calculate(
    FarmModel farm,
    WeatherModel weather,
    List<String> nearbyPlants,
  ) {
    // Rata-rata 3 hari terakhir + 24 jam terakhir.
    final recent = weather.history.length >= 3
        ? weather.history.sublist(weather.history.length - 3)
        : <DailyWeather>[];
    final wetAvg = recent.isEmpty
        ? weather.wetHours.toDouble()
        : (recent.fold(0, (s, d) => s + d.wetHours) + weather.wetHours) /
            (recent.length + 1);
    final t3 = weather.meanTemp(3);

    final tf = thermalSuitability(t3, 10, 25, 30, 35);
    // Peluang infeksi naik dengan lama basah dan jenuh setelah ±12 jam/hari.
    final wf = (wetAvg / 12).clamp(0.0, 1.0);
    final infection = tf * wf;

    final rain3f = weather.forecastRain(3);
    if (infection < 0.15 && rain3f < 10) {
      return PredictionService.buildResult(
        name,
        0.1,
        'Kondisi kering menghambat jamur.',
        'Rata-rata hanya ${_mm(wetAvg)} jam daun basah per hari. Spora membutuhkan lapisan air untuk berkecambah.',
        ['Jaga drainase dan jarak tanam agar tajuk cepat kering.'],
      );
    }

    final s = _Score(0.1);
    s.add(
      0.5 * infection,
      'Rata-rata ${_mm(wetAvg)} jam daun basah per hari pada suhu ${_c(t3)}°C${infection >= 0.5 ? ' cukup untuk spora berkecambah dan menginfeksi' : ''}.',
    );

    final rainy7 = weather.rainyDays(7);
    if (rainy7 >= 3) {
      s.add(0.1, 'Terjadi $rainy7 hari hujan dalam seminggu. Percikan air hujan menyebarkan spora antar tanaman.');
    }
    if (rain3f >= 20) {
      s.add(0.1, 'Prakiraan 3 hari ke depan: hujan ${_mm(rain3f)} mm. Lindungi buah sebelum hujan.');
    }
    if (weather.season == 'Musim Hujan') {
      s.add(0.05, 'Sedang musim hujan, periode serangan antraknosa paling berat.');
    }

    switch (farm.cropStage) {
      case CropStage.fruiting:
      case CropStage.harvesting:
        s.add(0.1, 'Buah cabai sedang terbentuk dan paling rentan busuk patek.');
      case CropStage.flowering:
        s.add(0.05, 'Fase berbunga menjelang pembentukan buah.');
      default:
        break;
    }
    if (_hadPestHistory(farm)) {
      s.add(0.1, 'Lahan pernah terserang. Jamur dapat bertahan di sisa tanaman dan menjadi sumber spora.');
    }

    return PredictionService.buildResult(
      name,
      s.value,
      'Daun basah dan hangat memicu spora jamur.',
      'Analisis risiko infeksi jamur:${s.bullets()}',
      [
        'Fungisida Protektif: Aplikasikan Mankozeb atau Propineb SEBELUM hujan turun.',
        'Fungisida Kuratif: Jika gejala muncul, gunakan Azoxystrobin atau Difenokonazol.',
        'Nutrisi: Tambahkan Kalsium (Ca) dan Boron (B) untuk mempertebal dinding sel buah.',
        'Sanitasi: Petik buah bergejala dan musnahkan jauh dari lahan.',
      ],
    );
  }
}

// ── Ulat Grayak (Spodoptera litura) ─────────────────────────────
// • Suhu optimum 30–35 °C; >35 °C menghambat dan betina tidak bertelur
//   <15 °C atau >35 °C; 38 °C mematikan larva (Fu et al., 2025; Fand et al.,
//   2015).
// • Ambang bawah perkembangan ±7,5–12 °C dengan konstanta termal ±420–590
//   derajat-hari (Maharjan et al., 2023).
// • Populasi larva berkorelasi positif dengan kelembapan (Dodiya et al.,
//   2024; Solanke et al., 2025) dan negatif dengan hujan lebat
//   (Solanke et al., 2025).
class ArmywormStrategy implements PestStrategy {
  static const name = 'Ulat Grayak';
  static const double _baseTemp = 9.5;
  static const double _thermalConstant = 530;

  @override
  PredictionResult? calculate(
    FarmModel farm,
    WeatherModel weather,
    List<String> nearbyPlants,
  ) {
    final t14 = weather.meanTemp(14);
    final rh7 = weather.meanHumidity(7);
    final rain7 = weather.rainTotal(7);
    final s = _Score(0.1);

    final thermal = thermalSuitability(t14, 15, 27, 34, 38);
    s.add(
      0.35 * thermal,
      thermal >= 0.7
          ? 'Suhu rata-rata ${_c(t14)}°C mendukung perkembangan dan peneluran ulat grayak.'
          : 'Suhu rata-rata ${_c(t14)}°C memperlambat perkembangan ulat grayak.',
    );

    if (weather.hasHistory) {
      final gen =
          weather.degreeDays(30, _baseTemp) / _thermalConstant;
      if (gen >= 0.8) {
        s.add(0.05, 'Akumulasi panas 30 hari cukup untuk ±${gen.toStringAsFixed(1)} generasi ulat grayak.');
      }
    }

    if (rh7 >= 75) {
      s.add(0.1, 'Kelembapan ${_mm(rh7)}% mendukung kelangsungan hidup larva.');
    }
    if (rain7 > 70) {
      s.add(-0.1, 'Hujan lebat ${_mm(rain7)} mm dalam 7 hari menekan populasi larva.');
    }
    if (farm.cropStage == CropStage.vegetative) {
      s.add(0.05, 'Daun muda fase vegetatif menjadi sasaran utama larva.');
    }
    if (farm.mulchType == MulchType.black) {
      // Asumsi lapangan tim, belum ada rujukan jurnal.
      s.add(0.1, 'Tanah di bawah mulsa hitam lembap dan hangat, bisa menjadi tempat pupa bersembunyi.');
    }
    if (_hadPestHistory(farm)) {
      s.add(0.05, 'Lahan pernah terserang hama, sehingga populasi awal mungkin sudah ada.');
    }

    return PredictionService.buildResult(
      name,
      s.value,
      'Suhu hangat dan lembap mendukung siklus hidup ulat.',
      'Faktor pendukung ulat grayak:${s.bullets()}',
      [
        'Pemantauan Malam: Ulat aktif di malam hari. Lakukan pengumpulan manual saat malam.',
        'Jebakan: Pasang perangkap Feromon Exi (untuk S. exigua) atau Litone (S. litura).',
        'Sanitasi: Bersihkan gulma di parit yang sering menjadi tempat bertelur.',
        'Insektisida: Gunakan bahan aktif Emamectin Benzoate atau Chlorantraniliprole.',
      ],
    );
  }
}

// ── Kutu Kebul (Bemisia tabaci) ─────────────────────────────────
// • Populasi tumbuh pada 13,9–33,4 °C (Sporleder et al., 2023); pertumbuhan
//   maksimum 26–28 °C (Aregbesola et al., 2020); puncak risiko ±27,5 °C
//   (Banda et al., 2026).
// • Ambang bawah 11,2 °C, satu generasi butuh 344,8 derajat-hari
//   (Khanh et al., 2021).
// • Hujan berpengaruh negatif, RH 55–70% mendukung (Katono et al., 2021);
//   efek pencucian oleh hujan (Sudiono & Purnomo, 2009).
// • Mendominasi fase vegetatif awal (Agustini et al., 2023).
class WhiteflyStrategy implements PestStrategy {
  static const name = 'Kutu Kebul (Virus Kuning)';
  static const double _baseTemp = 11.2;
  static const double _thermalConstant = 344.8;

  @override
  PredictionResult? calculate(
    FarmModel farm,
    WeatherModel weather,
    List<String> nearbyPlants,
  ) {
    final t14 = weather.meanTemp(14);
    final rh7 = weather.meanHumidity(7);
    final rain7 = weather.rainTotal(7);
    final s = _Score(0.1);

    final thermal = thermalSuitability(t14, 14, 26, 30, 33.5);
    s.add(
      0.35 * thermal,
      thermal >= 0.7
          ? 'Suhu rata-rata ${_c(t14)}°C mendekati suhu pertumbuhan populasi tercepat kutu kebul (26–28°C).'
          : 'Suhu rata-rata ${_c(t14)}°C memperlambat perkembangan kutu kebul.',
    );

    if (weather.hasHistory) {
      final gen = weather.degreeDays(30, _baseTemp) / _thermalConstant;
      if (gen >= 1) {
        s.add(0.05, 'Akumulasi panas 30 hari cukup untuk ±${gen.toStringAsFixed(1)} generasi baru kutu kebul.');
      }
    }

    if (rain7 > 50) {
      s.add(-0.15, 'Hujan ${_mm(rain7)} mm dalam 7 hari mencuci kutu kebul dari permukaan daun.');
    } else if (rain7 < 20) {
      s.add(0.1, 'Cuaca kering (${_mm(rain7)} mm hujan dalam 7 hari) membuat kutu kebul tidak tercuci.');
    }
    if (rh7 >= 55 && rh7 <= 75) {
      s.add(0.05, 'Kelembapan ${_mm(rh7)}% berada di rentang yang disukai kutu kebul.');
    }

    if (farm.cropStage == CropStage.seedling ||
        farm.cropStage == CropStage.vegetative) {
      s.add(0.2, 'Tanaman muda memiliki tunas lunak dan kaya nutrisi yang disukai kutu kebul.');
    }
    if (nearbyPlants.any(
      (p) => ['Terong', 'Melon', 'Semangka', 'Mentimun', 'Tomat'].contains(p),
    )) {
      s.add(0.1, 'Terdeteksi tanaman inang kutu kebul lain di sekitar lahan.');
    }
    if (_hadPestHistory(farm)) {
      s.add(0.05, 'Lahan pernah terserang hama, sehingga populasi awal mungkin sudah ada.');
    }
    if (farm.mulchType == MulchType.silver) {
      s.add(-0.1, 'Pantulan cahaya mulsa perak mengurangi hinggapnya kutu kebul.');
    }

    return PredictionService.buildResult(
      name,
      s.value,
      'Suhu hangat dan tunas muda memicu populasi kutu kebul.',
      'Potensi ledakan populasi kutu kebul:${s.bullets()}',
      [
        'Monitoring: Pasang Yellow Sticky Trap (Perangkap Kuning) 40 titik/ha untuk pantau populasi.',
        'Barier: Tanam Jagung di keliling lahan sebagai tanaman penghadang.',
        'Insektisida: Gunakan Imidakloprid (sistemik) atau Abamectin (kontak), rotasi wajib.',
        'Nutrisi: Hindari penggunaan Urea (N) berlebih agar daun tidak terlalu sukulen.',
      ],
    );
  }
}

// ── Prediction Service ───────────────────────────────────────

class PredictionService {
  final List<PestStrategy> _strategies = [
    ThripsStrategy(),
    FruitFlyStrategy(),
    AnthracnoseStrategy(),
    ArmywormStrategy(),
    WhiteflyStrategy(),
  ];

  List<PredictionResult> analyzeRisk(
    FarmModel? farm,
    WeatherModel weather,
    List<String> nearbyPlants,
  ) {
    if (farm == null) return [];
    final List<PredictionResult> results = [];

    for (final strategy in _strategies) {
      var result = strategy.calculate(farm, weather, nearbyPlants);
      if (result != null) {
        if (farm.lastPesticideTime.contains('< 3 hari')) {
          final double newPercentage = result.percentage * 0.2;
          result = buildResult(
            result.pestName,
            newPercentage,
            'Risiko terkendali (Pasca Semprot).',
            'Tanaman masih dilindungi oleh residu pestisida yang diaplikasikan < 3 hari lalu.',
            ['Lanjutkan jadwal monitoring rutin.'],
          );
        }
        if (result.percentage > 0.40) results.add(result);
      }
    }
    results.sort((a, b) => b.percentage.compareTo(a.percentage));
    return results;
  }

  /// Factory for building a [PredictionResult] with clamped score.
  static PredictionResult buildResult(
    String name,
    double score,
    String shortReason,
    String detailReason,
    List<String> steps,
  ) {
    score = score.clamp(0.0, 0.99);
    return PredictionResult(
      pestName: name,
      percentage: score,
      riskLevel: _getLevel(score),
      shortDescription: shortReason,
      detailedAnalysis: detailReason,
      preventionSteps: steps,
    );
  }

  static RiskLevel _getLevel(double score) {
    if (score > 0.7) return RiskLevel.severe;
    if (score > 0.5) return RiskLevel.high;
    if (score > 0.3) return RiskLevel.moderate;
    return RiskLevel.low;
  }
}
