// lib/models/operacao.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Operacao {
  final String id;
  final DateTime data;
  final String local;
  final String? descricao;
  final double? latitude;
  final double? longitude;
  final int? altitude;
  final double? pressaoAmbiente;
  final String? fotoOperacao;

  Operacao({
    String? id,
    required this.data,
    required this.local,
    this.descricao,
    this.latitude,
    this.longitude,
    this.altitude,
    this.pressaoAmbiente,
    this.fotoOperacao,
  }) : id = id ?? const Uuid().v4();

  factory Operacao.fromMap(Map<String, dynamic> map) {
    return Operacao(
      id: map['id'] as String?,                                   // agora String
      data: DateTime.parse(map['data'] as String),
      local: map['local'] as String,
      descricao: map['descricao'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      altitude: map['altitude'] as int?,
      pressaoAmbiente: (map['pressaoAmbiente'] as num?)?.toDouble(),
      fotoOperacao: map['fotoOperacao'] as String?,
    );
  }

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
      'fotoOperacao': fotoOperacao,
    };
  }
}
