import 'package:flutter/material.dart';
import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/services/database.dart';
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
    carregarOperacoes();
  }

  Future<void> carregarOperacoes() async {
    final db = await DatabaseService().database;
    final maps = await db.query('Operacao');
    setState(() {
      operacoes = maps.map((e) => Operacao.fromMap(e)).toList();
    });
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
            subtitle: Text(op.data),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetalheOperacaoScreen(operacao: op)),
              );
            },
          );
        },
      ),
    );
  }
}
