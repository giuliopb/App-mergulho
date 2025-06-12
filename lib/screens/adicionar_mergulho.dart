// lib/screens/adicionar_mergulho.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

import 'package:registro_mergulho/models/mergulho.dart';
import 'package:registro_mergulho/models/mergulhador.dart';
import 'package:registro_mergulho/services/mergulho_service.dart';
import 'package:registro_mergulho/services/mergulhador_service.dart';

class AdicionarMergulhoScreen extends StatefulWidget {
  final String operacaoId;
  final Mergulho? mergulho;

  const AdicionarMergulhoScreen({
    Key? key,
    required this.operacaoId,
    this.mergulho,
  }) : super(key: key);

  @override
  State<AdicionarMergulhoScreen> createState() =>
      _AdicionarMergulhoScreenState();
}

class _AdicionarMergulhoScreenState extends State<AdicionarMergulhoScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<Mergulhador> _mergulhadores;
  final Set<String> _selecionados = {};
  DateTime? _descida;
  DateTime? _subida;
  final _profMaxCtrl = TextEditingController();
  final _pressaoIniCtrl = TextEditingController();
  final _pressaoFimCtrl = TextEditingController();
  final _oQueFoiCtrl = TextEditingController();

  Position? _pos;
  File? _foto;

  @override
  void initState() {
    super.initState();
    // Carrega lista de mergulhadores
    MergulhadorService().getAll().then((lista) {
      setState(() => _mergulhadores = lista);
      if (widget.mergulho != null) _preencherFormulario();
    });
    // Pega localização atual
    _getLocation();
  }

  void _preencherFormulario() {
    final m = widget.mergulho!;
    _descida = m.horarioDescida;
    _subida = m.horarioSubida;
    _profMaxCtrl.text = m.profundidadeMax.toString();
    _pressaoIniCtrl.text = m.pressaoInicial.toString();
    _pressaoFimCtrl.text = m.pressaoFinal.toString();
    _oQueFoiCtrl.text = m.oQueFoiRealizado ?? '';
    _selecionados.add(m.mergulhadorId);
    if (m.latitude != null && m.longitude != null && m.altitude != null) {
      _pos = Position(
        latitude: m.latitude!,
        longitude: m.longitude!,
        timestamp: m.horarioDescida,
        accuracy: 0,
        altitude: m.altitude!.toDouble(),
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    if (m.fotoMergulho != null) {
      _foto = File(m.fotoMergulho!);
    }
  }

  Future<void> _getLocation() async {
    if (!await Permission.location.request().isGranted) return;
    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _pos = pos;
    });
  }

  Future<void> _pickDateTime({required bool isDescida}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return;
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isDescida) _descida = dt;
      else _subida = dt;
    });
  }

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selecionados.isEmpty || _descida == null || _subida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione mergulhadores e horários')),
      );
      return;
    }
    final fundo = _subida!.difference(_descida!).inMinutes;
    if (fundo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subida deve ser após descida')),
      );
      return;
    }
    final pressIni = int.tryParse(_pressaoIniCtrl.text.trim()) ?? 0;
    final pressFim = int.tryParse(_pressaoFimCtrl.text.trim()) ?? 0;
    if (pressIni < pressFim) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pressão inicial ≥ pressão final')),
      );
      return;
    }
    final profMax = int.tryParse(_profMaxCtrl.text.trim()) ?? 0;
    final descricao = _oQueFoiCtrl.text.trim();

    final service = MergulhoService();
    for (var id in _selecionados) {
      final merg = Mergulho(
        id: widget.mergulho?.id,
        operacaoId: widget.operacaoId,
        mergulhadorId: id,
        profundidadeMax: profMax,
        tempoFundo: fundo,
        horarioDescida: _descida!,
        horarioSubida: _subida!,
        pressaoInicial: pressIni,
        pressaoFinal: pressFim,
        latitude: _pos?.latitude,
        longitude: _pos?.longitude,
        altitude: _pos?.altitude.toInt(),
        fotoMergulho: _foto?.path,
        oQueFoiRealizado: descricao,
      );
      if (widget.mergulho == null) {
        await service.inserirMergulho(merg);
      } else {
        await service.atualizarMergulho(merg);
      }
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mergulho == null
            ? 'Adicionar Mergulho'
            : 'Editar Mergulho'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Selecione até 3 mergulhadores:'),
              ..._mergulhadores.map((m) => CheckboxListTile(
                    title: Text('${m.graduacao} ${m.nome}'),
                    value: _selecionados.contains(m.id),
                    onChanged: (v) {
                      setState(() {
                        if (v == true && _selecionados.length < 3)
                          _selecionados.add(m.id);
                        else
                          _selecionados.remove(m.id);
                      });
                    },
                  )),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_descida == null
                    ? 'Horário de Descída'
                    : DateFormat('dd/MM/yyyy HH:mm').format(_descida!)),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _pickDateTime(isDescida: true),
              ),
              ListTile(
                title: Text(_subida == null
                    ? 'Horário de Subida'
                    : DateFormat('dd/MM/yyyy HH:mm').format(_subida!)),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _pickDateTime(isDescida: false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _profMaxCtrl,
                decoration: const InputDecoration(
                    labelText: 'Profundidade Máxima (m)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'Informe a profundidade máxima'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pressaoIniCtrl,
                decoration: const InputDecoration(
                    labelText: 'Pressão inicial (bar)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'Informe pressão inicial'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pressaoFimCtrl,
                decoration: const InputDecoration(
                    labelText: 'Pressão final (bar)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'Informe pressão final'
                    : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_pos == null
                    ? 'Obter coordenadas'
                    : 'Lat:${_pos!.latitude.toStringAsFixed(5)}, Lon:${_pos!.longitude.toStringAsFixed(5)}'),
                trailing: const Icon(Icons.my_location),
                onTap: _getLocation,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_foto == null ? 'Tirar foto' : 'Foto capturada'),
                trailing: const Icon(Icons.camera_alt),
                onTap: _pickImage,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _oQueFoiCtrl,
                decoration:
                    const InputDecoration(labelText: 'O que foi realizado?'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
