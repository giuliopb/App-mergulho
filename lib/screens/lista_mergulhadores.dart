import 'package:flutter/material.dart';
import '../models/mergulhador.dart';
import '../services/mergulhador_service.dart';
import 'adicionar_mergulhador.dart';

class ListaMergulhadoresScreen extends StatefulWidget {
  const ListaMergulhadoresScreen({super.key});

  @override
  State<ListaMergulhadoresScreen> createState() => _ListaMergulhadoresScreenState();
}

class _ListaMergulhadoresScreenState extends State<ListaMergulhadoresScreen> {
  final _service = MergulhadorService();
  List<Mergulhador> _lista = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final l = await _service.buscarMergulhadores();
    setState(() => _lista = l);
  }

  void _adicionar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarMergulhadorScreen()),
    );
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mergulhadores')),
      body: ListView.builder(
        itemCount: _lista.length,
        itemBuilder: (ctx, i) {
          final m = _lista[i];
          return ListTile(
            title: Text('${m.graduacao} ${m.nome}'),
            subtitle: Text('Matrícula: ${m.matricula ?? "—"}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionar,
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Mergulhador',
      ),
    );
  }
}
