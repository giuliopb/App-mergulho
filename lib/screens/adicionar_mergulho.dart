import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:registro_mergulho/models/mergulho.dart';
import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/database.dart';
import 'package:registro_mergulho/services/mergulho_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:registro_mergulho/services/altitude_service.dart';
import 'package:permission_handler/permission_handler.dart';


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
  List<Mergulhador> mergulhadoresSelecionados = [];

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
      if (mergulhadoresSelecionados.isEmpty || mergulhadoresSelecionados.length > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione de 1 a 3 mergulhadores.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final tempoFundo = horarioSubida!.difference(horarioDescida!).inMinutes;

      final profundidade = int.parse(_profundidadeController.text.trim());
      final pressaoInicial = int.parse(_pressaoInicialController.text.trim());
      final pressaoFinal = int.parse(_pressaoFinalController.text.trim());

      final consumoTotal = pressaoInicial - pressaoFinal;
      final consumoPor10Min = consumoTotal / tempoFundo * 10;

      final posicao = await Geolocator.getCurrentPosition();
      final altitude = AltitudeService.arredondarAltitude(posicao.altitude.toInt());

      for (var m in mergulhadoresSelecionados) {
        final mergulho = Mergulho(
          operacaoId: widget.operacaoId,
          mergulhadorId: m.id,
          profundidadeMax: profundidade,
          tempoFundo: tempoFundo,
          horarioDescida: horarioDescida!,
          horarioSubida: horarioSubida!,
          pressaoInicial: pressaoInicial,
          pressaoFinal: pressaoFinal,
          latitude: posicao.latitude,
          longitude: posicao.longitude,
          altitude: altitude,
        );
        await MergulhoService().inserirMergulho(mergulho);
      }


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mergulho salvo. Consumo: ${consumoPor10Min.toStringAsFixed(1)} bar a cada 10 min.',
          ),
          duration: const Duration(hours: 1),
          action: SnackBarAction(
            label: 'X',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
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
              const Text(
                'Selecione até 3 mergulhadores:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...mergulhadores.map((m) {
                final selecionado = mergulhadoresSelecionados.contains(m);
                return CheckboxListTile(
                  title: Text('${m.graduacao} ${m.nome}'),
                  value: selecionado,
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        if (mergulhadoresSelecionados.length < 3) {
                          mergulhadoresSelecionados.add(m);
                        }
                      } else {
                        mergulhadoresSelecionados.remove(m);
                      }
                    });
                  },
                );
              }).toList(),
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
