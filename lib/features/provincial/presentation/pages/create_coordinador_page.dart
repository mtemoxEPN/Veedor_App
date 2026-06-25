import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class CreateCoordinadorPage extends StatefulWidget {
  final String recintoId;
  final String nombreRecinto;

  const CreateCoordinadorPage({super.key, required this.recintoId, required this.nombreRecinto});

  @override
  State<CreateCoordinadorPage> createState() => _CreateCoordinadorPageState();
}

class _CreateCoordinadorPageState extends State<CreateCoordinadorPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Asignar a: ${widget.nombreRecinto}')),
      body: BlocListener<ProvincialBloc, ProvincialState>(
        listener: (context, state) {
          if (state is ProvincialError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          } else if (state is ProvincialActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            Navigator.of(context).pop(); // Volver al panel provincial
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text('Se creará la cuenta del coordinador y se le asignará la clave "Ecuador2026" por defecto.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cedulaController,
                  decoration: const InputDecoration(labelText: 'Cédula (10 dígitos)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (v) => v!.length != 10 ? 'Cédula inválida' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombresController,
                  decoration: const InputDecoration(labelText: 'Nombres', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apellidosController,
                  decoration: const InputDecoration(labelText: 'Apellidos', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correoController,
                  decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<ProvincialBloc>().add(
                        CreateCoordinadorRecintoEvent(
                          cedula: _cedulaController.text,
                          nombres: _nombresController.text,
                          apellidos: _apellidosController.text,
                          telefono: _telefonoController.text,
                          correo: _correoController.text,
                          recintoId: widget.recintoId,
                        ),
                      );
                    }
                  },
                  child: const Text('Crear y Asignar Coordinador'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
