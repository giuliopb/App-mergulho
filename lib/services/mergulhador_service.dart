// lib/services/mergulhador_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/database.dart';

/// Serviço para operações CRUD de Mergulhador no banco SQLite
class MergulhadorService {
  final dbService = DatabaseService();

  Future<List<Mergulhador>> getAll() async {
    final db = await dbService.database;
    final res = await db.query('Mergulhador', orderBy: 'nome');
    return res.map((e) => Mergulhador.fromMap(e)).toList();
  }

  Future<int> insert(Mergulhador m) async {
    final db = await dbService.database;
    return db.insert('Mergulhador', m.toMap());
  }

  Future<int> update(Mergulhador m) async {
    final db = await dbService.database;
    return db.update(
      'Mergulhador',
      m.toMap(),
      where: 'id = ?',
      whereArgs: [m.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbService.database;
    return db.delete(
      'Mergulhador',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
