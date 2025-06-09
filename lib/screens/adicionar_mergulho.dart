import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_mergulho/models/mergulho.dart';
import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/database.dart';
import 'package:registro_mergulho/services/mergulho_service.dart';

class AdicionarMergulhoScreen extends StatefulWidget {
  final String operacaoId;

  const AdicionarMergulhoScreen({super.key, required this.operacaoId});

  @override
  State<AdicionarMergulhoScreen> createState() => _AdicionarMergulhoScreenState();
}

class _AdicionarMergulhoScreenState extends State<AdicionarMergulhoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profundidadeController = TextEditingController();
  final _pressaoInicialController = TextEditingController();
  final _pressaoFinalController = TextEditingController();

  List<Mergulhador> mergulhadores = [];
  Mergulhador? mergulhadorSelecionado;

  DateTime? horarioDescida;
  DateTime? horarioSubida;

  @override
  void initState() {
    super.initState();
    _carregarMergulhadores();
  }

  Future<void> _carregarMergulhadores() async {
    final db = await DatabaseService().database;
    final maps = await db.query('Mergulhador');
    setState(() {
      mergulhadores = maps.map((e) => Mergulhador.fromMap(e)).toList();
    });
  }

  Future<void> _selecionarHoraDescida() async {
    final agora = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(agora),
    );
    if (time != null) {
      setState(() {
        horarioDescida = DateTime(
          agora.year, agora.month, agora.day, time.hour, time.minute);
      });
    }
  }

  Future<void> _selecionarHoraSubida() async {
    final agora = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(agora),
    );
    if (time != null) {
      setState(() {
        horarioSubida = DateTime(
          agora.year, agora.month, agora.day, time.hour, time.minute);
      });
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate() && horarioDescida != null && horarioSubida != null) {
      final tempoFundo = horarioSubida!.difference(horarioDescida!).inMinutes;

      final profundidade = int.parse(_profundidadeController.text.trim());
      final pressaoInicial = int.parse(_pressaoInicialController.text.trim());
      final pressaoFinal = int.parse(_pressaoFinalController.text.trim());

      final consumoTotal = pressaoInicial - pressaoFinal;
      final consumoPor10Min = consumoTotal / tempoFundo * 10;

      final mergulho = Mergulho(
        operacaoId: widget.operacaoId,
        mergulhadorId: mergulhadorSelecionado!.id,
        profundidadeMax: profundidade,
        tempoFundo: tempoFundo,
        horarioDescida: horarioDescida!,
        horarioSubida: horarioSubida!,
        pressaoInicial: pressaoInicial,
        pressaoFinal: pressaoFinal,
      );

      await MergulhoService().inserirMergulho(mergulho);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mergulho salvo. Consumo: ${consumoPor10Min.toStringAsFixed(1)} bar a cada 10 min.',
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _profundidadeController.dispose();
    _pressaoInicialController.dispose();
    _pressaoFinalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Mergulho')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Mergulhador>(
                value: mergulhadorSelecionado,
                items: mergulhadores.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text("${m.graduacao} ${m.nome}"),
                  );
                }).toList(),
                onChanged: (m) => setState(() => mergulhadorSelecionado = m),
                decoration: const InputDecoration(labelText: 'Mergulhador'),
                validator: (value) => value == null ? 'Selecione o mergulhador' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _profundidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Profundidade Máxima (m)'),
                validator: (v) => v == null || v.isEmpty ? 'Informe a profundidade' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(horarioDescida == null
                    ? 'Selecionar horário de descida'
                    : 'Descida: ${DateFormat.Hm().format(horarioDescida!)}'),
                trailing: const Icon(Icons.schedule),
                onTap: _selecionarHoraDescida,
              ),
              ListTile(
                title: Text(horarioSubida == null
                    ? 'Selecionar horário de subida'
                    : 'Subida: ${DateFormat.Hm().format(horarioSubida!)}'),
                trailing: const Icon(Icons.schedule),
                onTap: _selecionarHoraSubida,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pressaoInicialController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pressão Inicial (bar)'),
                validator: (v) => v == null || v.isEmpty ? 'Informe a pressão inicial' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pressaoFinalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pressão Final (bar)'),
                validator: (v) => v == null || v.isEmpty ? 'Informe a pressão final' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar Mergulho'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
