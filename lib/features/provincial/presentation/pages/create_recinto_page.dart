import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class CreateRecintoPage extends StatefulWidget {
  const CreateRecintoPage({super.key});

  @override
  State<CreateRecintoPage> createState() => _CreateRecintoPageState();
}

class _CreateRecintoPageState extends State<CreateRecintoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cantonController = TextEditingController();
  final _parroquiaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _mesasController = TextEditingController();

  @override
  void dispose() {
    _cantonController.dispose();
    _parroquiaController.dispose();
    _nombreController.dispose();
    _mesasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Recinto')),
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
                TextFormField(
                  controller: _cantonController,
                  decoration: const InputDecoration(labelText: 'Cantón', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parroquiaController,
                  decoration: const InputDecoration(labelText: 'Parroquia', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del Recinto', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mesasController,
                  decoration: const InputDecoration(labelText: 'Cantidad de Mesas (JRV)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<ProvincialBloc>().add(
                        CreateRecintoEvent(
                          canton: _cantonController.text,
                          parroquia: _parroquiaController.text,
                          nombre: _nombreController.text,
                          cantidadMesas: int.parse(_mesasController.text),
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar Recinto'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
