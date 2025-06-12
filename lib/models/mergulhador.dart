import 'package:uuid/uuid.dart';

class Mergulhador {
  final String id;
  final String nome;
  final String matricula;
  final String graduacao;

  Mergulhador({
    String? id,
    required this.nome,
    required this.matricula,
    required this.graduacao,
  }) : id = id ?? const Uuid().v4();

  factory Mergulhador.fromMap(Map<String, dynamic> map) {
    return Mergulhador(
      id: map['id'] as String?,               // id é String no banco
      nome: map['nome'] as String,
      matricula: map['matricula'] as String,
      graduacao: map['graduacao'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'matricula': matricula,
      'graduacao': graduacao,
    };
  }
}
