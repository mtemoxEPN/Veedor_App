import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';

class CreateMesaPage extends StatefulWidget {
  final String recintoId;

  const CreateMesaPage({super.key, required this.recintoId});

  @override
  State<CreateMesaPage> createState() => _CreateMesaPageState();
}

class _CreateMesaPageState extends State<CreateMesaPage> {
  final _formKey = GlobalKey<FormState>();
  final _numeroMesaController = TextEditingController();

  @override
  void dispose() {
    _numeroMesaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Mesa')),
      body: BlocListener<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is RecintoError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          } else if (state is RecintoActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _numeroMesaController,
                  decoration: const InputDecoration(labelText: 'Número o Nombre de la Mesa', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<RecintoBloc>().add(
                        CreateMesaEvent(
                          numeroMesa: _numeroMesaController.text,
                          recintoId: widget.recintoId,
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar Mesa'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
