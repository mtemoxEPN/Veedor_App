import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
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
import '../../../provincial/presentation/pages/votos_consolidados_page.dart';
import '../../../provincial/domain/usecases/get_actas_count_by_recinto_usecase.dart';
import 'recinto_dashboard.dart';
import 'widgets/user_profile_card.dart';

class ProvincialDashboard extends StatefulWidget {
  final UserEntity user;
  const ProvincialDashboard({super.key, required this.user});

  @override
  State<ProvincialDashboard> createState() => _ProvincialDashboardState();
}

class _ProvincialDashboardState extends State<ProvincialDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.location_city_outlined),
            selectedIcon: Icon(Icons.location_city),
            label: 'Recintos',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildRecintosTab(context),
          VotosConsolidadosPage(user: widget.user),
        ],
      ),
    );
  }

  Widget _buildRecintosTab(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProvincialBloc>()..add(LoadRecintosEvent()),
      child: Scaffold(
        backgroundColor: AppTheme.secondary,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Panel Provincial',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Cerrar sesión',
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutRequestedEvent());
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              UserProfileCard(user: widget.user),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                    child: BlocBuilder<ProvincialBloc, ProvincialState>(
                      builder: (context, state) {
                        if (state is ProvincialLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ProvincialError) {
                          return _buildError(state.message, context);
                        } else if (state is ProvincialRecintosLoaded) {
                          final recintos = state.recintos;
                          if (recintos.isEmpty) {
                            return _buildEmpty(context);
                          }
                          return RefreshIndicator(
                            color: AppTheme.primary,
                            onRefresh: () async {
                              context.read<ProvincialBloc>().add(LoadRecintosEvent());
                              await Future<void>.delayed(const Duration(milliseconds: 400));
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 24, bottom: 80),
                              itemCount: recintos.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 24, bottom: 16, right: 24),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on, color: AppTheme.secondary),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Gestión de Recintos',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceMuted,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text('${recintos.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return _buildRecintoCard(context, recintos[index - 1]);
                              },
                            ),
                          );
                        }
                        return const Center(child: Text('Cargando datos...', style: TextStyle(color: AppTheme.textMuted)));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
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
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nuevo Recinto', style: TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppTheme.danger.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text('Error al cargar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              onPressed: () => context.read<ProvincialBloc>().add(LoadRecintosEvent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProvincialBloc>().add(LoadRecintosEvent());
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: ListView(
        padding: const EdgeInsets.only(top: 60),
        children: [
          Icon(Icons.location_city_outlined, size: 80, color: AppTheme.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          const Text(
            'No hay recintos registrados',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Presiona el botón + para crear uno nuevo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildRecintoCard(BuildContext context, dynamic recinto) {
    final hasCoordinador = recinto.coordinadorId != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance, color: AppTheme.secondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recinto.nombre,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recinto.canton} · ${recinto.parroquia}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                if (hasCoordinador)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                  )
                else
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProvincialBloc>(),
                            child: CreateCoordinadorPage(
                              recintoId: recinto.id,
                              nombreRecinto: recinto.nombre,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    color: AppTheme.warning,
                    style: IconButton.styleFrom(backgroundColor: AppTheme.warning.withValues(alpha: 0.15)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.table_rows, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${recinto.cantidadMesas} mesas',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Avance de Escrutinio',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            FutureBuilder(
              future: di.sl<GetActasCountByRecintoUseCase>()(recinto.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(minHeight: 6);
                }
                int actasSubidas = 0;
                if (snapshot.hasData) {
                  snapshot.data!.fold((l) => null, (r) => actasSubidas = r);
                }
                int actasTotalesEsperadas = recinto.cantidadMesas * 2;
                double progreso = actasTotalesEsperadas == 0 ? 0 : actasSubidas / actasTotalesEsperadas;
                final progressColor = progreso == 1.0 ? AppTheme.success : AppTheme.primary;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progreso,
                        backgroundColor: AppTheme.surfaceMuted,
                        color: progressColor,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$actasSubidas / $actasTotalesEsperadas actas',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        Text(
                          '${(progreso * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: progressColor),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    final mockUser = UserEntity(
                      id: widget.user.id,
                      cedula: widget.user.cedula,
                      nombres: 'Auditoría: ${recinto.nombre}',
                      apellidos: widget.user.apellidos,
                      rol: 'coordinador_recinto',
                      recintoId: recinto.id,
                      requiresPasswordChange: false,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecintoDashboard(user: mockUser),
                      ),
                    );
                  },
                  icon: const Icon(Icons.table_view, size: 16),
                  label: const Text('Auditar Mesas'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => VotosConsolidadosPage(user: widget.user)),
                    );
                  },
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: const Text('Ver votos'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
