import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/services/database.dart';

class OperacaoService {
  Future<void> inserirOperacao(Operacao operacao) async {
    final db = await DatabaseService().database;
    await db.insert('Operacao', operacao.toMap());
  }
}
