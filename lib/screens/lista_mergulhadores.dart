// lib/screens/lista_mergulhadores.dart
import 'package:flutter/material.dart';
import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/mergulhador_service.dart';
import 'adicionar_mergulhador.dart';

class MergulhadoresListScreen extends StatefulWidget {
  const MergulhadoresListScreen({Key? key}) : super(key: key);

  @override
  State<MergulhadoresListScreen> createState() =>
      _MergulhadoresListScreenState();
}

class _MergulhadoresListScreenState extends State<MergulhadoresListScreen> {
  final service = MergulhadorService();
  late Future<List<Mergulhador>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = service.getAll();
    });
  }

  void _delete(String id) async {
    await service.delete(id);
    _refresh();
  }

  void _openForm({Mergulhador? m}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdicionarMergulhadorScreen(mergulhador: m),
      ),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mergulhadores')),
      body: FutureBuilder<List<Mergulhador>>(
        future: _future,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar: ${snapshot.error}'),
            );
          }
          final list = snapshot.data;
          if (list == null || list.isEmpty) {
            return const Center(child: Text('Nenhum mergulhador cadastrado.'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final m = list[i];
              return ListTile(
                title: Text(m.nome),
                subtitle: Text('Matrícula: ${m.matricula}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(m: m),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Excluir?'),
                          content: Text('Remover ${m.nome}?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Não')),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _delete(m.id);
                              },
                              child: const Text('Sim'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _openForm(m: m),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
