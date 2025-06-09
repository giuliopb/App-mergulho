import 'package:flutter/material.dart';
import 'package:registro_mergulho/screens/home_screen.dart';
import 'package:registro_mergulho/services/database.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // EXCLUI O BANCO DE DADOS LOCAL ANTIGO — USE APENAS PARA TESTES
  final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'registro_mergulho.db'));

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Mergulho',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
/*

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DatabaseService().database;
  } catch (e) {
    debugPrint('Erro ao inicializar o banco de dados: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Mergulho',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
*/
