import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
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
  bool _submitting = false;

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
      backgroundColor: AppTheme.primary,
      body: BlocListener<ProvincialBloc, ProvincialState>(
        listener: (context, state) {
          if (state is ProvincialError) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.danger),
            );
          } else if (state is ProvincialActionSuccess) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.success),
            );
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 20, top: 10, bottom: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Crear Recinto',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.location_city, size: 24, color: AppTheme.primary),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Complete los datos del nuevo recinto electoral',
                                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _cantonController,
                              decoration: AppTheme.inputDecoration(label: 'Cantón', prefixIcon: Icons.place_outlined),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _parroquiaController,
                              decoration: AppTheme.inputDecoration(label: 'Parroquia', prefixIcon: Icons.map_outlined),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _nombreController,
                              decoration: AppTheme.inputDecoration(label: 'Nombre del Recinto', prefixIcon: Icons.business_outlined),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _mesasController,
                              decoration: AppTheme.inputDecoration(label: 'Cantidad de Mesas (JRV)', prefixIcon: Icons.table_rows),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: _submitting
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => _submitting = true);
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
                              child: _submitting
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Guardar Recinto', style: TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
