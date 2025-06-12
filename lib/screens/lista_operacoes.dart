// lib/screens/lista_operacoes.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/services/operacao_service.dart';
import 'adicionar_operacao.dart';
import 'detalhe_operacao.dart';

class ListaOperacoesScreen extends StatefulWidget {
  const ListaOperacoesScreen({Key? key}) : super(key: key);

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
    operacoes = await OperacaoService().buscarOperacoes();
    setState(() {});
  }

  void _navegarAdicionarOperacao() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarOperacaoScreen()),
    );
    if (result == true) await _carregarOperacoes();
  }

  void _editarOperacao(Operacao op) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdicionarOperacaoScreen(operacao: op)),
    );
    if (result == true) await _carregarOperacoes();
  }

  void _deletarOperacao(Operacao op) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir operação'),
        content: Text('Deseja remover a operação em ${op.local}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );
    if (confirm == true) {
      await OperacaoService().deletarOperacao(op.id);
      await _carregarOperacoes();
    }
  }

  void _navegarDetalhes(Operacao op) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalheOperacaoScreen(operacaoId: op.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operações')),
      body: operacoes.isEmpty
          ? const Center(child: Text('Nenhuma operação cadastrada.'))
          : ListView.builder(
              itemCount: operacoes.length,
              itemBuilder: (_, i) {
                final op = operacoes[i];
                return ListTile(
                  title: Text(op.local),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(op.data)),
                  onTap: () => _navegarDetalhes(op),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editarOperacao(op),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deletarOperacao(op),
                      ),
                    ],
                  ),
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
