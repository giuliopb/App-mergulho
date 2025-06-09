import 'package:uuid/uuid.dart';

class Operacao {
  String id;
  String data;
  String local;
  String? descricao;
  int altitude;
  double pressaoAmbiente;

  Operacao({
    String? id,
    required this.data,
    required this.local,
    this.descricao,
    required this.altitude,
    required this.pressaoAmbiente,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'local': local,
      'descricao': descricao,
      'altitude': altitude,
      'pressaoAmbiente': pressaoAmbiente,
    };
  }

  factory Operacao.fromMap(Map<String, dynamic> map) {
    return Operacao(
      id: map['id'],
      data: map['data'],
      local: map['local'],
      descricao: map['descricao'],
      altitude: map['altitude'],
      pressaoAmbiente: map['pressaoAmbiente'],
    );
  }
}
