import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/services/operacao_service.dart';
import 'package:registro_mergulho/services/altitude_service.dart';
import 'package:permission_handler/permission_handler.dart';

class AdicionarOperacaoScreen extends StatefulWidget {
  const AdicionarOperacaoScreen({super.key});

  @override
  State<AdicionarOperacaoScreen> createState() => _AdicionarOperacaoScreenState();
}

class _AdicionarOperacaoScreenState extends State<AdicionarOperacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _localController = TextEditingController();
  final _descricaoController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // 1) pedir permissão
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de localização negada')),
      );
      return;
    }

    try {
      // 2) obter posição (com altitude)
      final posicao = await Geolocator.getCurrentPosition();

      // 3) arredondar altitude
      final altitude =
          AltitudeService.arredondarAltitude(posicao.altitude.toInt());

      // 4) calcular pressão ambiente, se quiser registrar
      final pressaoAmb = AltitudeService.calcularPressaoAmbiente(altitude);

      final operacao = Operacao(
        data: _dataSelecionada,
        local: _localController.text.trim(),
        descricao: _descricaoController.text.trim(),
        latitude: posicao.latitude,
        longitude: posicao.longitude,
        altitude: altitude,
        pressaoAmbiente: pressaoAmb,
      );

      await OperacaoService().inserirOperacao(operacao);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Operação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // data
              ListTile(
                title: Text('Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final nova = await showDatePicker(
                    context: context,
                    initialDate: _dataSelecionada,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (nova != null) {
                    setState(() => _dataSelecionada = nova);
                  }
                },
              ),
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(labelText: 'Local'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o local' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar Operação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
