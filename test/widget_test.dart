// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A importação deve bater com o "name:" do pubspec.yaml
import 'package:registro_mergulho/main.dart';

void main() {
  testWidgets('App carrega e mostra título na HomeScreen', (WidgetTester tester) async {
    // Constrói o widget
    await tester.pumpWidget(const MyApp());

    // Aguarda possíveis animações
    await tester.pumpAndSettle();

    // Verifica se o texto da HomeScreen está presente
    expect(find.text('Bem-vindo ao App de Mergulho'), findsOneWidget);
  });
}
