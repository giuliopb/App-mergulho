// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'lista_mergulhadores.dart';
import 'lista_operacoes.dart';
import 'historico_mergulho.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Mergulho')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Mergulhadores'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MergulhadoresListScreen()),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Operações'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListaOperacoesScreen()),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Mergulhos'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoricoMergulhoScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
