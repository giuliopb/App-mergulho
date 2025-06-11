import 'package:registro_mergulho/models/mergulho.dart';
import 'package:registro_mergulho/services/database.dart';
import 'package:sqflite/sqflite.dart';

/// Serviço para operações CRUD de Mergulho no banco SQLite
class MergulhoService {
  /// Insere um novo mergulho
  Future<void> inserirMergulho(Mergulho mergulho) async {
    final Database db = await DatabaseService().database;
    await db.insert(
      'Mergulho',
      mergulho.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca todos os mergulhos de uma operação, ordenados por horário de descida
  Future<List<Mergulho>> buscarMergulhosPorOperacao(String operacaoId) async {
    final Database db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Mergulho',
      where: 'operacao_id = ?',
      whereArgs: [operacaoId],
      orderBy: 'horario_descida ASC',
    );
    return maps.map((m) => Mergulho.fromMap(m)).toList();
  }

  /// (Opcional) Atualiza um mergulho existente
  Future<void> atualizarMergulho(Mergulho mergulho) async {
    final Database db = await DatabaseService().database;
    await db.update(
      'Mergulho',
      mergulho.toMap(),
      where: 'id = ?',
      whereArgs: [mergulho.id],
    );
  }

  /// (Opcional) Remove um mergulho
  Future<void> deletarMergulho(String id) async {
    final Database db = await DatabaseService().database;
    await db.delete(
      'Mergulho',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
