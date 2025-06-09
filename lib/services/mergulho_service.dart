import 'package:registro_mergulho/models/mergulho.dart';
import 'package:registro_mergulho/services/database.dart';

class MergulhoService {
  Future<void> inserirMergulho(Mergulho mergulho) async {
    final db = await DatabaseService().database;
    await db.insert('Mergulho', mergulho.toMap());
  }

  Future<List<Mergulho>> buscarMergulhosPorOperacao(String operacaoId) async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      'Mergulho',
      where: 'operacao_id = ?',
      whereArgs: [operacaoId],
    );
    return maps.map((e) => Mergulho.fromMap(e)).toList();
  }
}
