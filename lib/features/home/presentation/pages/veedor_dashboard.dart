import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../veedor/presentation/bloc/veedor_bloc.dart';
import '../../../veedor/presentation/bloc/veedor_event.dart';
import '../../../veedor/presentation/bloc/veedor_state.dart';
import '../../../veedor/presentation/pages/acta_form_page.dart';

class VeedorDashboard extends StatelessWidget {
  final UserEntity user;

  const VeedorDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<VeedorBloc>()..add(LoadMesasByVeedorEvent(user.userId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Panel de Veedor: ${user.nombres}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequestedEvent());
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            )
          ],
        ),
        body: BlocBuilder<VeedorBloc, VeedorState>(
          builder: (context, state) {
            if (state is VeedorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VeedorError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is VeedorMesasListLoaded) {
              final mesas = state.mesas;
              if (mesas.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No tienes mesas asignadas en este momento.', textAlign: TextAlign.center),
                  ),
                );
              }
              return ListView.builder(
                itemCount: mesas.length,
                itemBuilder: (context, index) {
                  final mesa = mesas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      leading: const Icon(Icons.how_to_vote, color: Colors.blue),
                      title: Text('Mesa ${mesa.numeroMesa}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Estado: ${mesa.estado}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Seleccione el acta a registrar o editar:', textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              _buildActaButton(context, 'Alcalde', mesa.id, mesa.recintoId),
                              const SizedBox(height: 12),
                              _buildActaButton(context, 'Prefecto', mesa.id, mesa.recintoId),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Cargando tus mesas asignadas...'));
          },
        ),
      ),
    );
  }

  Widget _buildActaButton(BuildContext context, String tipoActa, String mesaId, String recintoId) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => di.sl<VeedorBloc>()..add(CheckActaStatusEvent(mesaId, tipoActa)),
              child: Scaffold(
                appBar: AppBar(title: Text('Acta de $tipoActa')),
                body: BlocBuilder<VeedorBloc, VeedorState>(
                  builder: (context, state) {
                    if (state is VeedorLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is VeedorActaStatus) {
                      if (state.acta != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 80),
                              const SizedBox(height: 16),
                              Text('El acta de $tipoActa ya fue reportada.', style: const TextStyle(fontSize: 18)),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<VeedorBloc>(),
                                        child: ActaFormPage(
                                          mesaId: mesaId, 
                                          recintoId: recintoId, 
                                          tipoActa: tipoActa,
                                          actaExistente: state.acta,
                                        ),
                                      )
                                    ),
                                  );
                                },
                                child: const Text('Editar Acta'),
                              )
                            ],
                          ),
                        );
                      }
                      return BlocProvider.value(
                        value: context.read<VeedorBloc>(),
                        child: ActaFormPage(mesaId: mesaId, recintoId: recintoId, tipoActa: tipoActa),
                      );
                    } else if (state is VeedorError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const Center(child: Text('Cargando estado...'));
                  },
                ),
              ),
            )
          ),
        );
      },
      icon: const Icon(Icons.assignment),
      label: Text('Acta de $tipoActa'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
