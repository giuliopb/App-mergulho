import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:registro_mergulho/screens/home_screen.dart';
import 'package:registro_mergulho/services/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // APAGAR O BANCO ANTIGO
  final path = join(await getDatabasesPath(), 'registro_mergulho.db');
  await deleteDatabase(path);

  await DatabaseService().database;
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
import 'package:flutter/material.dart';
import 'package:registro_mergulho/screens/home_screen.dart';
import 'package:registro_mergulho/services/database.dart';

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
} */
