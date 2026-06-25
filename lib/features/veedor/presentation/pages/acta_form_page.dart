import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/acta_entity.dart';
import '../../domain/services/sharpness_validator.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import '../bloc/veedor_state.dart';

class ActaFormPage extends StatefulWidget {
  final String mesaId;
  final String recintoId;
  final String tipoActa;
  final ActaEntity? actaExistente;

  const ActaFormPage({
    super.key,
    required this.mesaId,
    required this.recintoId,
    required this.tipoActa,
    this.actaExistente,
  });

  @override
  State<ActaFormPage> createState() => _ActaFormPageState();
}

class _ActaFormPageState extends State<ActaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _novedadesController = TextEditingController();
  final _votos1Controller = TextEditingController(text: '0');
  final _votos2Controller = TextEditingController(text: '0');
  final _votos3Controller = TextEditingController(text: '0');
  final _votos4Controller = TextEditingController(text: '0');
  final _votos5Controller = TextEditingController(text: '0');
  final _votosBlancosController = TextEditingController(text: '0');
  final _votosNulosController = TextEditingController(text: '0');
  final _totalSufragantesController = TextEditingController(text: '0');
  
  File? _imageFile;
  String? _existingFotoUrl;
  final ImagePicker _picker = ImagePicker();
  final SharpnessValidator _sharpnessValidator = SharpnessValidator();

  @override
  void initState() {
    super.initState();
    if (widget.actaExistente != null) {
      final acta = widget.actaExistente!;
      _novedadesController.text = acta.novedades;
      _votos1Controller.text = acta.votosCandidato1.toString();
      _votos2Controller.text = acta.votosCandidato2.toString();
      _votos3Controller.text = acta.votosCandidato3.toString();
      _votos4Controller.text = acta.votosCandidato4.toString();
      _votos5Controller.text = acta.votosCandidato5.toString();
      _votosBlancosController.text = acta.votosBlancos.toString();
      _votosNulosController.text = acta.votosNulos.toString();
      _totalSufragantesController.text = acta.totalSufragantes.toString();
      _existingFotoUrl = acta.fotoUrl;
    }
  }

  @override
  void dispose() {
    _novedadesController.dispose();
    _votos1Controller.dispose();
    _votos2Controller.dispose();
    _votos3Controller.dispose();
    _votos4Controller.dispose();
    _votos5Controller.dispose();
    _votosBlancosController.dispose();
    _votosNulosController.dispose();
    _totalSufragantesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analizando nitidez de la foto...'), duration: Duration(seconds: 1)));
      }
      
      // Validación real de nitidez usando Laplacian Variance
      // Ejecutar la validación en un isolate usando compute para no congelar la UI
      final bool esNitida = await compute(
        _verificarNitidezEnIsolate,
        pickedFile.path,
      );
      
      if (!esNitida && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La foto está borrosa o no es legible. Por favor, tome otra foto.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          )
        );
        return; // No se guarda la imagen borrosa
      }

      setState(() {
        _imageFile = File(pickedFile.path);
        _existingFotoUrl = null; // Clear existing if new one picked
      });
    }
  }

  Future<Position?> _obtenerUbicacion() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Los servicios de ubicación están desactivados.')));
      }
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permisos de ubicación denegados.')));
        }
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permisos de ubicación denegados permanentemente.'),
            action: SnackBarAction(
              label: 'Ajustes',
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          )
        );
      }
      return null;
    } 

    return await Geolocator.getCurrentPosition();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null && _existingFotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe adjuntar la foto del acta'), backgroundColor: Colors.red));
      return;
    }

    int v1 = int.tryParse(_votos1Controller.text) ?? 0;
    int v2 = int.tryParse(_votos2Controller.text) ?? 0;
    int v3 = int.tryParse(_votos3Controller.text) ?? 0;
    int v4 = int.tryParse(_votos4Controller.text) ?? 0;
    int v5 = int.tryParse(_votos5Controller.text) ?? 0;
    int blancos = int.tryParse(_votosBlancosController.text) ?? 0;
    int nulos = int.tryParse(_votosNulosController.text) ?? 0;
    int total = int.tryParse(_totalSufragantesController.text) ?? 0;

    // Validación individual
    bool individualInvalido = [v1, v2, v3, v4, v5, blancos, nulos].any((v) => v > total);
    if (individualInvalido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validación Fallida: Los votos de un partido/blanco/nulo no pueden superar al total de sufragantes.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        )
      );
      return;
    }

    int sumaCalculada = v1 + v2 + v3 + v4 + v5 + blancos + nulos;
    
    if (sumaCalculada != total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Validación Fallida: La suma de votos ($sumaCalculada) no coincide con el total de sufragantes ($total).'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        )
      );
      return;
    }

    // Obtener GPS
    Position? position = await _obtenerUbicacion();
    double lat = position?.latitude ?? 0.0;
    double lng = position?.longitude ?? 0.0;

    if (!mounted) return;

    context.read<VeedorBloc>().add(
      SubmitActaEvent(
        mesaId: widget.mesaId,
        recintoId: widget.recintoId,
        tipoActa: widget.tipoActa,
        novedades: _novedadesController.text,
        imagePath: _imageFile?.path ?? _existingFotoUrl ?? '',
        votosCandidato1: v1,
        votosCandidato2: v2,
        votosCandidato3: v3,
        votosCandidato4: v4,
        votosCandidato5: v5,
        votosBlancos: blancos,
        votosNulos: nulos,
        totalSufragantes: total,
        latitud: lat,
        longitud: lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VeedorBloc, VeedorState>(
      listener: (context, state) {
        if (state is VeedorError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        } else if (state is VeedorActaSubmittedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Acta subida con éxito'), backgroundColor: Colors.green));
          context.read<VeedorBloc>().add(CheckActaStatusEvent(widget.mesaId, widget.tipoActa));
          Navigator.of(context).pop(); // Regresar al dashboard después de enviar
        }
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Registro de Acta: ${widget.tipoActa}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildNumberField(_votos1Controller, 'Votos Partido A'),
            _buildNumberField(_votos2Controller, 'Votos Partido B'),
            _buildNumberField(_votos3Controller, 'Votos Partido C'),
            _buildNumberField(_votos4Controller, 'Votos Partido D'),
            _buildNumberField(_votos5Controller, 'Votos Partido E'),
            _buildNumberField(_votosBlancosController, 'Votos en Blanco'),
            _buildNumberField(_votosNulosController, 'Votos Nulos'),
            _buildNumberField(_totalSufragantesController, 'Total de Sufragantes (Suma Total)', isHighlight: true),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _novedadesController,
              decoration: const InputDecoration(labelText: 'Novedades (Opcional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text('Foto del Acta Física', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 200, fit: BoxFit.cover)
            else if (_existingFotoUrl != null && _existingFotoUrl!.isNotEmpty)
              Image.network(_existingFotoUrl!, height: 200, fit: BoxFit.cover)
            else
              Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(child: Text('Ninguna foto seleccionada')),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _submitForm,
              child: const Text('ENVIAR ACTA AL CNE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label, 
          border: const OutlineInputBorder(),
          filled: isHighlight,
          fillColor: isHighlight ? Colors.blue.shade50 : null,
        ),
        keyboardType: TextInputType.number,
        validator: (v) => v!.isEmpty ? 'Requerido' : null,
      ),
    );
  }
}

// Función top-level o estática para que pueda ejecutarse en compute()
Future<bool> _verificarNitidezEnIsolate(String path) async {
  return await SharpnessValidator().isSharp(path);
}
