import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/database.dart';
import 'package:sqflite/sqflite.dart';

/// Serviço para operações CRUD de Mergulhador no banco SQLite
class MergulhadorService {
  /// Insere um novo mergulhador
  Future<void> inserirMergulhador(Mergulhador mergulhador) async {
    final Database db = await DatabaseService().database;
    await db.insert(
      'Mergulhador',
      mergulhador.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca todos os mergulhadores, ordenados por nome
  Future<List<Mergulhador>> buscarMergulhadores() async {
    final Database db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Mergulhador',
      orderBy: 'nome COLLATE NOCASE',
    );
    return List.generate(
      maps.length,
      (i) => Mergulhador.fromMap(maps[i]),
    );
  }

  /// Atualiza um mergulhador existente
  Future<void> atualizarMergulhador(Mergulhador mergulhador) async {
    final Database db = await DatabaseService().database;
    await db.update(
      'Mergulhador',
      mergulhador.toMap(),
      where: 'id = ?',
      whereArgs: [mergulhador.id],
    );
  }

  /// Remove um mergulhador pelo ID
  Future<void> deletarMergulhador(String id) async {
    final Database db = await DatabaseService().database;
    await db.delete(
      'Mergulhador',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
