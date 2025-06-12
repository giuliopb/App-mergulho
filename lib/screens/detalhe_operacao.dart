// lib/screens/detalhe_operacao.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/models/mergulho.dart';
import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/database.dart';
import 'package:registro_mergulho/services/mergulho_service.dart';
import 'package:registro_mergulho/services/operacao_service.dart';
import 'package:registro_mergulho/services/altitude_service.dart';
import 'package:registro_mergulho/services/naui_service.dart';

import 'adicionar_mergulho.dart';

class DetalheOperacaoScreen extends StatefulWidget {
  final String operacaoId;
  const DetalheOperacaoScreen({Key? key, required this.operacaoId}) : super(key: key);

  @override
  State<DetalheOperacaoScreen> createState() => _DetalheOperacaoScreenState();
}

class _DetalheOperacaoScreenState extends State<DetalheOperacaoScreen> {
  Operacao? _operacao;
  List<Mergulho> _todosMergulhos = [];
  Map<String, Mergulhador> _mergulhadoresMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    // Carrega mergulhadores
    final db = await DatabaseService().database;
    final mapsM = await db.query('Mergulhador');
    final listaM = mapsM.map((m) => Mergulhador.fromMap(m)).toList();
    final mapM = { for (var m in listaM) m.id: m };

    // Carrega mergulhos da operação
    final listaD = await MergulhoService().buscarMergulhosPorOperacao(widget.operacaoId);

    // Carrega operação
    final ops = await OperacaoService().buscarOperacoes();
    final oper = ops.firstWhere((o) => o.id == widget.operacaoId);

    setState(() {
      _operacao = oper;
      _mergulhadoresMap = mapM;
      _todosMergulhos = listaD;
      _isLoading = false;
    });
  }

  void _navegarAdicionarMergulho([Mergulho? mergulho]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarMergulhoScreen(
          operacaoId: widget.operacaoId,
          mergulho: mergulho,
        ),
      ),
    );
    if (changed == true) await _carregarDados();
  }

  void _excluirMergulho(Mergulho m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir mergulho?'),
        content: Text('Remover mergulho de ${DateFormat('dd/MM/yyyy HH:mm').format(m.horarioDescida)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );
    if (confirm == true) {
      await MergulhoService().deletarMergulho(m.id!);
      await _carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _operacao == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhe da Operação')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final oper = _operacao!;
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
            Text('Data: ${DateFormat('dd/MM/yyyy').format(oper.data)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Local: ${oper.local}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Descrição: ${oper.descricao}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navegarAdicionarMergulho(),
              child: const Text('Adicionar Mergulho'),
            ),
            const SizedBox(height: 16),
            const Text('Mergulhos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: grupos.isEmpty
                  ? const Center(child: Text('Nenhum mergulho registrado.'))
                  : ListView.builder(
                      itemCount: grupos.length,
                      itemBuilder: (context, index) {
                        final entry = grupos[index];
                        final primeiro = entry.value.first;
                        final nomes = entry.value.map((m) {
                          final mer = _mergulhadoresMap[m.mergulhadorId];
                          return '${mer?.graduacao} ${mer?.nome}';
                        }).join(', ');
                        final pressaoAmb = AltitudeService.calcularPressaoAmbiente(oper.altitude ?? 0);
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${index + 1} - $nomes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => _navegarAdicionarMergulho(primeiro),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          onPressed: () => _excluirMergulho(primeiro),
                                        ),
                                      ],
                                    ),
                                  ],
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
