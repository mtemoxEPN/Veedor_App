import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
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
  bool _submitting = false;

  @override
  void dispose() {
    _numeroMesaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: BlocListener<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is RecintoError) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.danger),
            );
          } else if (state is RecintoActionSuccess) {
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
                      'Crear Mesa',
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
                                  Icon(Icons.table_rows, size: 24, color: AppTheme.primary),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Registre una nueva mesa electoral (JRV) en este recinto.',
                                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _numeroMesaController,
                              decoration: AppTheme.inputDecoration(label: 'Número o Nombre de la Mesa', prefixIcon: Icons.tag),
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
                                        context.read<RecintoBloc>().add(
                                          CreateMesaEvent(
                                            numeroMesa: _numeroMesaController.text,
                                            recintoId: widget.recintoId,
                                          ),
                                        );
                                      }
                                    },
                              child: _submitting
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Guardar Mesa', style: TextStyle(fontSize: 16)),
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
