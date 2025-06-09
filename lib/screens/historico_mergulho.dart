import 'package:flutter/material.dart';
import 'package:registro_mergulho/models/mergulho.dart';
import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/services/database.dart';

class HistoricoMergulhoScreen extends StatefulWidget {
  const HistoricoMergulhoScreen({super.key});

  @override
  State<HistoricoMergulhoScreen> createState() => _HistoricoMergulhoScreenState();
}

class _HistoricoMergulhoScreenState extends State<HistoricoMergulhoScreen> {
  List<_MergulhoCompleto> mergulhosCompletos = [];

  @override
  void initState() {
    super.initState();
    carregarMergulhosCompletos();
  }

  Future<void> carregarMergulhosCompletos() async {
    final db = await DatabaseService().database;
    final mergulhosMap = await db.query('Mergulho');

    List<_MergulhoCompleto> lista = [];

    for (var map in mergulhosMap) {
      final mergulho = Mergulho.fromMap(map);

      final operacaoMap = await db.query(
        'Operacao',
        where: 'id = ?',
        whereArgs: [mergulho.operacaoId],
        limit: 1,
      );

      final mergulhadorMap = await db.query(
        'Mergulhador',
        where: 'id = ?',
        whereArgs: [mergulho.mergulhadorId],
        limit: 1,
      );

      if (operacaoMap.isNotEmpty && mergulhadorMap.isNotEmpty) {
        final operacao = Operacao.fromMap(operacaoMap.first);
        final mergulhador = Mergulhador.fromMap(mergulhadorMap.first);

        lista.add(_MergulhoCompleto(
          mergulho: mergulho,
          operacao: operacao,
          mergulhador: mergulhador,
        ));
      }
    }

    setState(() {
      mergulhosCompletos = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Mergulhos')),
      body: ListView.builder(
        itemCount: mergulhosCompletos.length,
        itemBuilder: (context, index) {
          final item = mergulhosCompletos[index];
          return ListTile(
            title: Text('${item.operacao.data} - ${item.operacao.local}'),
            subtitle: Text('${item.mergulhador.graduacao} ${item.mergulhador.nome}\n'
                'Profundidade: ${item.mergulho.profundidadeMax} m - Tempo: ${item.mergulho.tempoFundo} min'),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}

class _MergulhoCompleto {
  final Mergulho mergulho;
  final Operacao operacao;
  final Mergulhador mergulhador;

  _MergulhoCompleto({
    required this.mergulho,
    required this.operacao,
    required this.mergulhador,
  });
}
