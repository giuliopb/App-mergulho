import 'package:uuid/uuid.dart';

class Mergulho {
  String id;
  String operacaoId;
  String mergulhadorId;
  int profundidadeMax;
  int tempoFundo;
  DateTime horarioDescida;
  DateTime horarioSubida;
  int pressaoInicial;
  int pressaoFinal;

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
  }) : id = id ?? const Uuid().v4();

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
    };
  }

  factory Mergulho.fromMap(Map<String, dynamic> map) {
    return Mergulho(
      id: map['id'],
      operacaoId: map['operacao_id'],
      mergulhadorId: map['mergulhador_id'],
      profundidadeMax: map['profundidade_max'],
      tempoFundo: map['tempo_fundo'],
      horarioDescida: DateTime.parse(map['horario_descida']),
      horarioSubida: DateTime.parse(map['horario_subida']),
      pressaoInicial: map['pressao_inicial'],
      pressaoFinal: map['pressao_final'],
    );
  }
}
