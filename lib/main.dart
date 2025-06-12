// lib/main.dart
import 'package:flutter/material.dart';
import 'package:registro_mergulho/screens/home_screen.dart';
import 'package:registro_mergulho/screens/lista_mergulhadores.dart';
import 'package:registro_mergulho/screens/lista_operacoes.dart';
import 'package:registro_mergulho/screens/adicionar_mergulhador.dart';
import 'package:registro_mergulho/screens/adicionar_operacao.dart';
import 'package:registro_mergulho/screens/adicionar_mergulho.dart';
import 'package:registro_mergulho/screens/detalhe_operacao.dart';
import 'package:registro_mergulho/screens/historico_mergulho.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // Removi o construtor const pra combinar com seus widgets
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Mergulho',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => HomeScreen());
          case '/mergulhadores':
            return MaterialPageRoute(builder: (_) => MergulhadoresListScreen());
          case '/operacoes':
            return MaterialPageRoute(builder: (_) => ListaOperacoesScreen());
          case '/adicionarMergulhador':
            return MaterialPageRoute(builder: (_) => AdicionarMergulhadorScreen());
          case '/adicionarOperacao':
            return MaterialPageRoute(builder: (_) => AdicionarOperacaoScreen());
          case '/detalheOperacao':
            final opId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => DetalheOperacaoScreen(
                // Convertendo para String, pois seu widget espera String operacaoId
                operacaoId: opId.toString(),
              ),
            );
          case '/adicionarMergulho':
            final opId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => AdicionarMergulhoScreen(
                operacaoId: opId.toString(),
              ),
            );
          case '/historicoMergulho':
            return MaterialPageRoute(builder: (_) => HistoricoMergulhoScreen());
          default:
            return null; // rota desconhecida
        }
      },
    );
  }
}
