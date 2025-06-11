import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/services/operacao_service.dart';
import 'adicionar_operacao.dart';
import 'detalhe_operacao.dart';

class ListaOperacoesScreen extends StatefulWidget {
  const ListaOperacoesScreen({super.key});

  @override
  State<ListaOperacoesScreen> createState() => _ListaOperacoesScreenState();
}

class _ListaOperacoesScreenState extends State<ListaOperacoesScreen> {
  List<Operacao> operacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarOperacoes();
  }

  Future<void> _carregarOperacoes() async {
    final lista = await OperacaoService().buscarOperacoes();
    setState(() => operacoes = lista);
  }

  void _navegarAdicionarOperacao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarOperacaoScreen()),
    );
    _carregarOperacoes(); // atualiza após voltar
  }

  void _navegarDetalhes(Operacao op) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalheOperacaoScreen(operacao: op)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operações')),
      body: ListView.builder(
        itemCount: operacoes.length,
        itemBuilder: (context, index) {
          final op = operacoes[index];
          return ListTile(
            title: Text(op.local),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(op.data)),
            onTap: () => _navegarDetalhes(op),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarAdicionarOperacao,
        child: const Icon(Icons.add),
      ),
    );
  }
}
