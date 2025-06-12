// lib/screens/adicionar_operacao.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:registro_mergulho/models/operacao.dart';
import 'package:registro_mergulho/services/operacao_service.dart';

class AdicionarOperacaoScreen extends StatefulWidget {
  final Operacao? operacao;
  const AdicionarOperacaoScreen({Key? key, this.operacao}) : super(key: key);

  @override
  State<AdicionarOperacaoScreen> createState() => _AdicionarOperacaoScreenState();
}

class _AdicionarOperacaoScreenState extends State<AdicionarOperacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dataCtrl;
  final _localCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _altCtrl = TextEditingController();

  Position? _pos;
  File? _foto;
  late bool _isNew;

  @override
  void initState() {
    super.initState();
    _isNew = widget.operacao == null;
    final now = DateTime.now();
    _dataCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.operacao?.data ?? now),
    );
    if (!_isNew) {
      final o = widget.operacao!;
      _localCtrl.text = o.local;
      _descCtrl.text = o.descricao ?? '';
      _altCtrl.text = o.altitude?.toString() ?? '';
      if (o.fotoOperacao != null) _foto = File(o.fotoOperacao!);
    }
    _getLocation();
  }

  Future<void> _getLocation() async {
    if (!await Permission.location.request().isGranted) return;
    final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _pos = p;
      _altCtrl.text = p.altitude.round().toString();
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: widget.operacao?.data ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      _dataCtrl.text = DateFormat('dd/MM/yyyy').format(d);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  void _delete() async {
    if (_isNew) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir operação?'),
        content: Text('Remover operação em ${_localCtrl.text}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );
    if (confirm == true) {
      await OperacaoService().deletarOperacao(widget.operacao!.id);
      Navigator.pop(context, true);
    }
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final dt = DateFormat('dd/MM/yyyy').parse(_dataCtrl.text);
    final oper = Operacao(
      id: widget.operacao?.id,
      data: dt,
      local: _localCtrl.text.trim(),
      descricao: _descCtrl.text.trim(),
      latitude: _pos?.latitude,
      longitude: _pos?.longitude,
      altitude: int.tryParse(_altCtrl.text.trim()) ?? 0,
      pressaoAmbiente: null,
      fotoOperacao: _foto?.path,
    );
    if (_isNew) {
      await OperacaoService().inserirOperacao(oper);
    } else {
      await OperacaoService().atualizarOperacao(oper);
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Nova Operação' : 'Editar Operação'),
        actions: [
          if (!_isNew)
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dataCtrl,
                decoration: InputDecoration(
                  labelText: 'Data',
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate),
                ),
                readOnly: true,
                validator: (v) => v == null || v.isEmpty ? 'Informe a data' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _localCtrl,
                decoration: const InputDecoration(labelText: 'Local'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o local' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
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
              TextFormField(
                controller: _altCtrl,
                decoration: const InputDecoration(labelText: 'Altitude (m)'),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_foto == null ? 'Tirar foto' : 'Foto capturada'),
                trailing: const Icon(Icons.camera_alt),
                onTap: _pickImage,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(_isNew ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
