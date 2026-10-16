import 'prediction_result.dart';

enum FarmRiskState { loading, safe, watch, danger, error }

/// Ringkasan risiko satu lahan untuk kartu Beranda.
class FarmRiskStatus {
  final FarmRiskState state;
  final String? pestName;
  final String? percentText;

  const FarmRiskStatus._(this.state, {this.pestName, this.percentText});

  const FarmRiskStatus.loading() : this._(FarmRiskState.loading);
  const FarmRiskStatus.error() : this._(FarmRiskState.error);
  const FarmRiskStatus.safe() : this._(FarmRiskState.safe);

  /// [top] adalah hasil risiko tertinggi; null berarti tidak ada risiko berarti.
  factory FarmRiskStatus.fromTop(PredictionResult? top) {
    if (top == null) return const FarmRiskStatus.safe();
    final danger = top.riskLevel == RiskLevel.severe;
    return FarmRiskStatus._(
      danger ? FarmRiskState.danger : FarmRiskState.watch,
      pestName: top.pestName,
      percentText: top.formattedPercentage,
    );
  }

  String get label {
    switch (state) {
      case FarmRiskState.loading:
        return 'Memeriksa...';
      case FarmRiskState.safe:
        return 'Aman';
      case FarmRiskState.watch:
        return 'Waspada: $pestName $percentText';
      case FarmRiskState.danger:
        return 'Bahaya: $pestName $percentText';
      case FarmRiskState.error:
        return 'Belum bisa dicek';
    }
  }
}
