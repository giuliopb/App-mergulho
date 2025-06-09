import 'dart:math';

class AltitudeService {
  /// Calcula pressão ambiente em ATM baseado na altitude
  static double calcularPressaoAmbiente(int altitudeMetros) {
    // Fórmula simplificada (até 3000m):
    return double.parse((1.0 * pow(0.984, altitudeMetros / 100)).toStringAsFixed(3));
  }

  /// Faz o arredondamento de segurança da altitude (sempre para cima de 50m)
  static int arredondarAltitude(int altitudeReal) {
    return ((altitudeReal + 49) ~/ 50) * 50;
  }
}
