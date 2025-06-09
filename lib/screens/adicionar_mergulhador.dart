import 'package:flutter/material.dart';
import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/mergulhador_service.dart';

class AdicionarMergulhadorScreen extends StatefulWidget {
  const AdicionarMergulhadorScreen({super.key});

  @override
  State<AdicionarMergulhadorScreen> createState() => _AdicionarMergulhadorScreenState();
}

class _AdicionarMergulhadorScreenState extends State<AdicionarMergulhadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _matriculaController = TextEditingController();

  final List<String> graduacoes = [
    'Sd',
    'Cb',
    '3º Sgt',
    '2º Sgt',
    '1º Sgt',
    'Sub Ten'
  ];

  String? _graduacaoSelecionada;

  @override
  void dispose() {
    _nomeController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novoMergulhador = Mergulhador(
        nome: _nomeController.text.trim(),
        matricula: _matriculaController.text.trim(),
        graduacao: _graduacaoSelecionada!,
      );

      await MergulhadorService().inserirMergulhador(novoMergulhador);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mergulhador salvo com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  String? _validarMatricula(String? value) {
    final regex = RegExp(r'^\d{6,7}-\d$');
    if (value == null || value.isEmpty) return 'Informe a matrícula';
    if (!regex.hasMatch(value)) return 'Formato inválido (ex: 719806-0)';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Mergulhador')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _matriculaController,
                decoration: const InputDecoration(labelText: 'Matrícula'),
                validator: _validarMatricula,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _graduacaoSelecionada,
                decoration: const InputDecoration(labelText: 'Graduação'),
                items: graduacoes
                    .map((grad) => DropdownMenuItem(
                          value: grad,
                          child: Text(grad),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _graduacaoSelecionada = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione a graduação' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
