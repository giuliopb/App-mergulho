import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/services/operacao_service.dart';
import 'package:registro_mergulho/services/altitude_service.dart';

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

  int? altitude;
  double? pressaoAmbiente;
  bool carregandoAltitude = false;

  @override
  void initState() {
    super.initState();
    obterAltitude();
  }

  Future<void> obterAltitude() async {
    setState(() {
      carregandoAltitude = true;
    });

    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      int altitudeReal = pos.altitude.round();
      int altArredondada = AltitudeService.arredondarAltitude(altitudeReal);
      double pressao = AltitudeService.calcularPressaoAmbiente(altArredondada);

      setState(() {
        altitude = altArredondada;
        pressaoAmbiente = pressao;
      });
    } catch (e) {
      setState(() {
        altitude = 0;
        pressaoAmbiente = 1.0;
      });
    }

    setState(() {
      carregandoAltitude = false;
    });
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final operacao = Operacao(
        data: DateFormat('yyyy-MM-dd').format(_dataSelecionada),
        local: _localController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
        altitude: altitude ?? 0,
        pressaoAmbiente: pressaoAmbiente ?? 1.0,
      );

      await OperacaoService().inserirOperacao(operacao);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Operação salva com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  Future<void> _selecionarData() async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataSelecionada = dataEscolhida;
      });
    }
  }

  @override
  void dispose() {
    _localController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataFormatada = DateFormat('dd/MM/yyyy').format(_dataSelecionada);

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Operação')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selecionarData,
                  ),
                ),
                controller: TextEditingController(text: dataFormatada),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(labelText: 'Local'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o local' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
              ),
              const SizedBox(height: 32),
              carregandoAltitude
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Altitude (arredondada): ${altitude ?? "N/A"} metros'),
                        Text('Pressão ambiente: ${pressaoAmbiente?.toStringAsFixed(2) ?? "N/A"} atm'),
                        const SizedBox(height: 16),
                      ],
                    ),
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
