import 'package:flutter/material.dart';
import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/models/mergulho.dart';
import 'package:registro_mergulho/services/mergulho_service.dart';
import 'package:registro_mergulho/services/naui_service.dart';
import 'adicionar_mergulho.dart';

class DetalheOperacaoScreen extends StatefulWidget {
  final Operacao operacao;

  const DetalheOperacaoScreen({super.key, required this.operacao});

  @override
  State<DetalheOperacaoScreen> createState() => _DetalheOperacaoScreenState();
}

class _DetalheOperacaoScreenState extends State<DetalheOperacaoScreen> {
  List<Mergulho> mergulhos = [];

  @override
  void initState() {
    super.initState();
    carregarMergulhos();
  }

  Future<void> carregarMergulhos() async {
    final lista = await MergulhoService().buscarMergulhosPorOperacao(widget.operacao.id);
    setState(() {
      mergulhos = lista;
    });
  }

  void _navegarAdicionarMergulho() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarMergulhoScreen(operacaoId: widget.operacao.id),
      ),
    );
    carregarMergulhos(); // atualiza após adicionar mergulho
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da Operação')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${widget.operacao.data}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Local: ${widget.operacao.local}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Descrição: ${widget.operacao.descricao ?? 'Sem descrição'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navegarAdicionarMergulho,
              child: const Text('Adicionar Mergulho'),
            ),
            const SizedBox(height: 24),
            const Text('Mergulhos cadastrados:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: mergulhos.length,
                itemBuilder: (context, index) {
                  final m = mergulhos[index];

                  final grupo = NauiService.calcularGrupoNaui(
                    m.profundidadeMax!,
                    m.tempoFundo!,
                    widget.operacao.pressaoAmbiente,
                  );

                  final percentual = NauiService.grupoNauiParaPercentual(grupo);
                  final cor = percentual >= 70 ? Colors.red : Colors.black;

                  return ListTile(
                    title: Text('Profundidade: ${m.profundidadeMax} m'),
                    subtitle: Text('Tempo de fundo: ${m.tempoFundo} min'),
                    trailing: Text(
                      '$grupo (${percentual}%)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: cor),
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
