import 'package:flutter/material.dart';
import 'adicionar_mergulhador.dart';
import 'package:registro_mergulho/screens/adicionar_operacao.dart';
import 'package:registro_mergulho/screens/lista_operacoes.dart';
import 'package:registro_mergulho/screens/historico_mergulho.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Mergulho')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton( //                   adicionar mergulhador
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdicionarMergulhadorScreen()),
                );
              },
              child: const Text('Adicionar Mergulhador'),
            ),
            const SizedBox(height: 20),
            ElevatedButton( //                        adicionar operações
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdicionarOperacaoScreen()),
                );
              },
              child: const Text('Adicionar Operação'),
            ),
            ElevatedButton( //                      lista de operaçoes
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListaOperacoesScreen()),
                );
              },
              child: const Text('Ver Operações'),
            ),
            ElevatedButton( //                        historico de mergulho
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoricoMergulhoScreen()),
                );
              },
              child: const Text('Histórico de Mergulhos'),
            ),

          ],
        ),
      ),
    );
  }
}
