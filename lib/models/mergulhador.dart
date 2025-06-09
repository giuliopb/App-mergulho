import 'package:uuid/uuid.dart';

class Mergulhador {
  String id;
  String nome;
  String matricula;
  String graduacao;

  Mergulhador({
    String? id,
    required this.nome,
    required this.matricula,
    required this.graduacao,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'matricula': matricula,
      'graduacao': graduacao,
    };
  }

  factory Mergulhador.fromMap(Map<String, dynamic> map) {
    return Mergulhador(
      id: map['id'],
      nome: map['nome'],
      matricula: map['matricula'],
      graduacao: map['graduacao'],
    );
  }
}
