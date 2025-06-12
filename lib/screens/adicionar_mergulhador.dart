import 'package:flutter/material.dart';
import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/mergulhador_service.dart';

class AdicionarMergulhadorScreen extends StatefulWidget {
  final Mergulhador? mergulhador;   // << parâmetro opcional
  const AdicionarMergulhadorScreen({Key? key, this.mergulhador}) : super(key: key);

  @override
  State<AdicionarMergulhadorScreen> createState() => _AdicionarMergulhadorScreenState();
}

class _AdicionarMergulhadorScreenState extends State<AdicionarMergulhadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _matriculaController = TextEditingController();
  final List<String> graduacoes = ['Sd','Cb','3º Sgt','2º Sgt','1º Sgt','Sub Ten'];
  String? _graduacaoSelecionada;

  @override
  void initState() {
    super.initState();
    if (widget.mergulhador != null) {
      _nomeController.text = widget.mergulhador!.nome;
      _matriculaController.text = widget.mergulhador!.matricula;
      _graduacaoSelecionada = widget.mergulhador!.graduacao;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final m = Mergulhador(
      id: widget.mergulhador?.id,
      nome: _nomeController.text.trim(),
      matricula: _matriculaController.text.trim(),
      graduacao: _graduacaoSelecionada!,
    );

    final service = MergulhadorService();
    if (widget.mergulhador == null) {
      await service.insert(m);
    } else {
      await service.update(m);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.mergulhador == null
          ? 'Mergulhador criado'
          : 'Mergulhador atualizado')),
    );
    Navigator.pop(context, true);
  }

  String? _validarMatricula(String? v) {
    final regex = RegExp(r'^\d{6,7}-\d$');
    if (v == null || v.isEmpty) return 'Informe a matrícula';
    if (!regex.hasMatch(v)) return 'Formato inválido (ex: 719806-0)';
    return null;
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mergulhador == null
            ? 'Novo Mergulhador'
            : 'Editar Mergulhador'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (v) => v==null||v.isEmpty ? 'Informe o nome' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _matriculaController,
                decoration: InputDecoration(labelText: 'Matrícula'),
                validator: _validarMatricula,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _graduacaoSelecionada,
                decoration: InputDecoration(labelText: 'Graduação'),
                items: graduacoes.map((g)=>DropdownMenuItem(
                  value: g, child: Text(g),
                )).toList(),
                onChanged: (v)=>setState(()=>_graduacaoSelecionada=v),
                validator: (v)=> v==null ? 'Selecione a graduação': null,
              ),
              SizedBox(height: 32),
              ElevatedButton(onPressed: _salvar, child: Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
