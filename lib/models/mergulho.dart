// lib/models/mergulho.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Mergulho {
  final String id;
  final String operacaoId;
  final String mergulhadorId;
  final int profundidadeMax;
  final int tempoFundo;
  final DateTime horarioDescida;
  final DateTime horarioSubida;
  final int pressaoInicial;
  final int pressaoFinal;
  final double? latitude;
  final double? longitude;
  final int? altitude;
  final String? fotoMergulho;
  final String? oQueFoiRealizado;

  Mergulho({
    String? id,
    required this.operacaoId,
    required this.mergulhadorId,
    required this.profundidadeMax,
    required this.tempoFundo,
    required this.horarioDescida,
    required this.horarioSubida,
    required this.pressaoInicial,
    required this.pressaoFinal,
    this.latitude,
    this.longitude,
    this.altitude,
    this.fotoMergulho,
    this.oQueFoiRealizado,
  }) : id = id ?? const Uuid().v4();

  factory Mergulho.fromMap(Map<String, dynamic> map) {
    return Mergulho(
      id: map['id'] as String?,
      operacaoId: map['operacao_id'] as String,
      mergulhadorId: map['mergulhador_id'] as String,
      profundidadeMax: map['profundidade_max'] as int? ?? 0,
      tempoFundo: map['tempo_fundo'] as int? ?? 0,
      horarioDescida: DateTime.parse(map['horario_descida'] as String),
      horarioSubida: DateTime.parse(map['horario_subida'] as String),
      pressaoInicial: map['pressao_inicial'] as int? ?? 0,
      pressaoFinal: map['pressao_final'] as int? ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      altitude: map['altitude'] as int?,
      fotoMergulho: map['foto_mergulho'] as String?,
      oQueFoiRealizado: map['o_que_foi_realizado'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operacao_id': operacaoId,
      'mergulhador_id': mergulhadorId,
      'profundidade_max': profundidadeMax,
      'tempo_fundo': tempoFundo,
      'horario_descida': horarioDescida.toIso8601String(),
      'horario_subida': horarioSubida.toIso8601String(),
      'pressao_inicial': pressaoInicial,
      'pressao_final': pressaoFinal,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'foto_mergulho': fotoMergulho,
      'o_que_foi_realizado': oQueFoiRealizado,
    };
  }
}
