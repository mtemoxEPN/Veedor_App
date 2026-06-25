import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../recinto/presentation/bloc/recinto_bloc.dart';
import '../../../recinto/presentation/bloc/recinto_event.dart';
import '../../../recinto/presentation/bloc/recinto_state.dart';
import '../../../recinto/presentation/pages/create_mesa_page.dart';
import '../../../recinto/presentation/pages/create_veedor_page.dart';
import '../../../recinto/presentation/pages/actas_list_page.dart';

class RecintoDashboard extends StatelessWidget {
  final UserEntity user;

  const RecintoDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RecintoBloc>()..add(LoadMesasEvent(user.recintoId ?? '')),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Panel de Recinto: ${user.nombres}'),
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
        body: BlocListener<RecintoBloc, RecintoState>(
          listenWhen: (prev, curr) => curr is RecintoActionSuccess,
          listener: (context, state) {
            if (state is RecintoActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            }
          },
          child: BlocBuilder<RecintoBloc, RecintoState>(
            builder: (context, state) {
              if (user.recintoId == null || user.recintoId!.isEmpty) {
                return const Center(child: Text('Error: No tienes un recinto asignado.'));
              }
              if (state is RecintoLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RecintoError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is RecintoMesasLoaded) {
                final mesas = state.mesas;
                if (mesas.isEmpty) {
                  return const Center(child: Text('No hay mesas registradas en este recinto.'));
                }
                return ListView.builder(
                  itemCount: mesas.length,
                  itemBuilder: (context, index) {
                    final mesa = mesas[index];
                    final hasVeedor = mesa.veedorId != null;
                    return ListTile(
                      title: Text('Mesa: ${mesa.numeroMesa}'),
                      subtitle: Text('Veedor: ${hasVeedor ? "Asignado" : "Pendiente"}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Ver actas de la mesa',
                            icon: const Icon(Icons.assignment, color: Colors.blue),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ActasListPage(
                                    mesaId: mesa.id,
                                    numeroMesa: mesa.numeroMesa,
                                    recintoId: user.recintoId!,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(hasVeedor ? Icons.edit : Icons.person_add, color: hasVeedor ? Colors.grey : Colors.orange),
                            onPressed: () {
                              // Asignar o reasignar veedor
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<RecintoBloc>(),
                                    child: CreateVeedorPage(
                                      mesaId: mesa.id,
                                      numeroMesa: mesa.numeroMesa,
                                      recintoId: user.recintoId!,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text('Cargando mesas...'));
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            if (user.recintoId == null || user.recintoId!.isEmpty) return const SizedBox.shrink();
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<RecintoBloc>(),
                      child: CreateMesaPage(recintoId: user.recintoId!),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          }
        ),
      ),
    );
  }
}
