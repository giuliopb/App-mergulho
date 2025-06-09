import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/database.dart';

class MergulhadorService {
  Future<void> inserirMergulhador(Mergulhador mergulhador) async {
    final db = await DatabaseService().database;
    await db.insert('Mergulhador', mergulhador.toMap());
  }
}
