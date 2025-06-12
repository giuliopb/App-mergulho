import 'package:flutter/material.dart';
import '../models/mergulhador.dart';
import '../services/mergulhador_service.dart';

class MergulhadorFormScreen extends StatefulWidget {
  final Mergulhador? mergulhador;
  MergulhadorFormScreen({this.mergulhador});

  @override
  _MergulhadorFormScreenState createState() => _MergulhadorFormScreenState();
}

class _MergulhadorFormScreenState extends State<MergulhadorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _matCtrl = TextEditingController();
  final _gradCtrl = TextEditingController();
  final service = MergulhadorService();

  @override
  void initState() {
    super.initState();
    if (widget.mergulhador != null) {
      _nomeCtrl.text = widget.mergulhador!.nome;
      _matCtrl.text = widget.mergulhador!.matricula;
      _gradCtrl.text = widget.mergulhador!.graduacao;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final m = Mergulhador(
      id: widget.mergulhador?.id,
      nome: _nomeCtrl.text.trim(),
      matricula: _matCtrl.text.trim(),
      graduacao: _gradCtrl.text.trim(),
    );
    if (widget.mergulhador == null) {
      await service.insert(m);
    } else {
      await service.update(m);
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mergulhador == null ? 'Novo Mergulhador' : 'Editar Mergulhador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _matCtrl,
                decoration: InputDecoration(labelText: 'Matrícula'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _gradCtrl,
                decoration: InputDecoration(labelText: 'Graduação'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _save,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
