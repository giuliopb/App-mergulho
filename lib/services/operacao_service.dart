import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/services/database.dart';

class OperacaoService {
  /// Insere uma nova operação
  Future<void> inserirOperacao(Operacao operacao) async {
    final db = await DatabaseService().database;
    await db.insert('Operacao', operacao.toMap());
  }

  /// Busca todas as operações, ordenadas da mais recente para a mais antiga
  Future<List<Operacao>> buscarOperacoes() async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      'Operacao',
      orderBy: 'data DESC',
    );
    return maps.map((m) => Operacao.fromMap(m)).toList();
  }

  /// Busca uma única operação pelo ID
  Future<Operacao?> buscarOperacaoPorId(String id) async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      'Operacao',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Operacao.fromMap(maps.first);
    }
    return null;
  }

  /// Atualiza os dados de uma operação existente
  Future<void> atualizarOperacao(Operacao operacao) async {
    final db = await DatabaseService().database;
    await db.update(
      'Operacao',
      operacao.toMap(),
      where: 'id = ?',
      whereArgs: [operacao.id],
    );
  }

  /// Remove uma operação pelo ID
  Future<void> deletarOperacao(String id) async {
    final db = await DatabaseService().database;
    await db.delete(
      'Operacao',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
