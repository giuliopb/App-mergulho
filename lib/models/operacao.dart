import 'package:uuid/uuid.dart';

class Operacao {
  final String id;
  final DateTime data;
  final String local;
  final String descricao;
  final double? latitude;
  final double? longitude;
  final int? altitude;
  final double? pressaoAmbiente;

  Operacao({
    String? id,
    required this.data,
    required this.local,
    required this.descricao,
    this.latitude,
    this.longitude,
    this.altitude,
    this.pressaoAmbiente,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data.toIso8601String(),
      'local': local,
      'descricao': descricao,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'pressaoAmbiente': pressaoAmbiente,
    };
  }

  factory Operacao.fromMap(Map<String, dynamic> map) {
    return Operacao(
      id: map['id'],
      data: DateTime.parse(map['data']),
      local: map['local'],
      descricao: map['descricao'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      altitude: map['altitude'],
      pressaoAmbiente: map['pressaoAmbiente']?.toDouble(),
    );
  }
}
