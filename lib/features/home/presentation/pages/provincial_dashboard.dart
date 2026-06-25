import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../provincial/presentation/bloc/provincial_bloc.dart';
import '../../../provincial/presentation/bloc/provincial_event.dart';
import '../../../provincial/presentation/bloc/provincial_state.dart';
import '../../../provincial/presentation/pages/create_recinto_page.dart';
import '../../../provincial/presentation/pages/create_coordinador_page.dart';
import '../../../provincial/domain/usecases/get_actas_count_by_recinto_usecase.dart';

class ProvincialDashboard extends StatelessWidget {
  final UserEntity user;

  const ProvincialDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProvincialBloc>()..add(LoadRecintosEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Panel Provincial: ${user.nombres}'),
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
        body: BlocBuilder<ProvincialBloc, ProvincialState>(
          builder: (context, state) {
            if (state is ProvincialLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProvincialError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is ProvincialRecintosLoaded) {
              final recintos = state.recintos;
              if (recintos.isEmpty) {
                return const Center(child: Text('No hay recintos registrados. Crea uno.'));
              }
              return ListView.builder(
                itemCount: recintos.length,
                itemBuilder: (context, index) {
                  final recinto = recintos[index];
                  final hasCoordinador = recinto.coordinadorId != null;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('${recinto.nombre} (${recinto.canton} - ${recinto.parroquia})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Mesas: ${recinto.cantidadMesas} | Coord: ${hasCoordinador ? "Asignado" : "Pendiente"}'),
                            trailing: hasCoordinador 
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : IconButton(
                                    icon: const Icon(Icons.person_add, color: Colors.orange),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<ProvincialBloc>(),
                                            child: CreateCoordinadorPage(recintoId: recinto.id, nombreRecinto: recinto.nombre),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Avance de Escrutinio:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          FutureBuilder(
                            future: di.sl<GetActasCountByRecintoUseCase>()(recinto.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const LinearProgressIndicator();
                              }
                              int actasSubidas = 0;
                              if (snapshot.hasData) {
                                snapshot.data!.fold((l) => null, (r) => actasSubidas = r);
                              }
                              int actasTotalesEsperadas = recinto.cantidadMesas * 2; // Alcalde + Prefecto
                              double progreso = actasTotalesEsperadas == 0 ? 0 : actasSubidas / actasTotalesEsperadas;
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: progreso,
                                    backgroundColor: Colors.grey[300],
                                    color: progreso == 1.0 ? Colors.green : Colors.blue,
                                    minHeight: 8,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$actasSubidas / $actasTotalesEsperadas actas recibidas (${(progreso * 100).toStringAsFixed(1)}%)',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Cargando datos...'));
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProvincialBloc>(),
                      child: const CreateRecintoPage(),
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
