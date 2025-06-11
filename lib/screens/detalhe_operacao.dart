import 'package:flutter/material.dart';
import '../models/operacao.dart';
import '../models/mergulho.dart';
import '../models/mergulhador.dart';
import '../services/database.dart';
import '../services/mergulho_service.dart';    // import relativo
import '../services/naui_service.dart';
import '../services/altitude_service.dart';
import 'adicionar_mergulho.dart';

class DetalheOperacaoScreen extends StatefulWidget {
  final Operacao operacao;
  const DetalheOperacaoScreen({super.key, required this.operacao});

  @override
  State<DetalheOperacaoScreen> createState() => _DetalheOperacaoScreenState();
}

class _DetalheOperacaoScreenState extends State<DetalheOperacaoScreen> {
  List<Mergulho> _todosMergulhos = [];
  Map<String, Mergulhador> _mergulhadoresMap = {};

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final db = await DatabaseService().database;
    final maps = await db.query('Mergulhador');
    final listaM = maps.map((m) => Mergulhador.fromMap(m)).toList();
    final mapM = { for (var m in listaM) m.id: m };

    // Use o serviço importado corretamente
    final lista = await MergulhoService()
        .buscarMergulhosPorOperacao(widget.operacao.id);

    setState(() {
      _mergulhadoresMap = mapM;
      _todosMergulhos = lista;
    });
  }

  void _navegarAdicionarMergulho() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdicionarMergulhoScreen(operacaoId: widget.operacao.id),
      ),
    );
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Mergulho>>{};
    for (var m in _todosMergulhos) {
      final key = m.horarioDescida.toIso8601String();
      grouped.putIfAbsent(key, () => []).add(m);
    }
    final grupos = grouped.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da Operação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data: ${widget.operacao.data}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Local: ${widget.operacao.local}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Descrição: ${widget.operacao.descricao}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navegarAdicionarMergulho,
              child: const Text('Adicionar Mergulho'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mergulhos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: grupos.length,
                itemBuilder: (context, index) {
                  final entry = grupos[index];
                  final listaMergs = entry.value;
                  final nomes = listaMergs.map((m) {
                    final mer = _mergulhadoresMap[m.mergulhadorId];
                    return '${mer?.graduacao ?? ''} ${mer?.nome ?? ''}'.trim();
                  }).join(' e ');
                  final primeiro = listaMergs.first;
                  final pressaoAmb = AltitudeService
                      .calcularPressaoAmbiente(widget.operacao.altitude ?? 0);
                  final grupoNaui = NauiService.calcularGrupoNaui(
                    primeiro.profundidadeMax,
                    primeiro.tempoFundo,
                    pressaoAmb,
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1} - $nomes',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text('Profundidade: ${primeiro.profundidadeMax} m'),
                          Text('Tempo de fundo: ${primeiro.tempoFundo} min'),
                          Text('Grupo NAUI: $grupoNaui'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
