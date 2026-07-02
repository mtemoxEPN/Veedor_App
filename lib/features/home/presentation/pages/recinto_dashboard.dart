import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
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
import '../../../provincial/presentation/pages/votos_consolidados_page.dart';
import 'widgets/user_profile_card.dart';

class RecintoDashboard extends StatefulWidget {
  final UserEntity user;
  const RecintoDashboard({super.key, required this.user});

  @override
  State<RecintoDashboard> createState() => _RecintoDashboardState();
}

class _RecintoDashboardState extends State<RecintoDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return _buildMesasTab(context);
  }

  Widget _buildMesasTab(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RecintoBloc>()..add(LoadMesasEvent(widget.user.recintoId ?? '')),
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
                      'Panel Recinto',
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
                    child: BlocListener<RecintoBloc, RecintoState>(
                      listenWhen: (prev, curr) => curr is RecintoActionSuccess,
                      listener: (context, state) {
                        if (state is RecintoActionSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message), backgroundColor: AppTheme.success),
                          );
                        }
                      },
                      child: BlocBuilder<RecintoBloc, RecintoState>(
                        builder: (context, state) {
                          if (widget.user.recintoId == null || widget.user.recintoId!.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text('Error: No tienes un recinto asignado.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.danger)),
                              ),
                            );
                          }
                          if (state is RecintoLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is RecintoError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline, size: 56, color: AppTheme.danger.withValues(alpha: 0.7)),
                                    const SizedBox(height: 16),
                                    Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
                                    const SizedBox(height: 20),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('Reintentar'),
                                      onPressed: () => context.read<RecintoBloc>().add(LoadMesasEvent(widget.user.recintoId!)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is RecintoMesasLoaded) {
                            final mesas = state.mesas;
                            if (mesas.isEmpty) {
                              return RefreshIndicator(
                                color: AppTheme.primary,
                                onRefresh: () async {
                                  context.read<RecintoBloc>().add(LoadMesasEvent(widget.user.recintoId!));
                                  await Future<void>.delayed(const Duration(milliseconds: 400));
                                },
                                child: ListView(
                                  padding: const EdgeInsets.only(top: 60),
                                  children: [
                                    Icon(Icons.table_rows_outlined, size: 80, color: AppTheme.textMuted.withValues(alpha: 0.3)),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'No hay mesas registradas',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return RefreshIndicator(
                              color: AppTheme.primary,
                              onRefresh: () async {
                                context.read<RecintoBloc>().add(LoadMesasEvent(widget.user.recintoId!));
                                await Future<void>.delayed(const Duration(milliseconds: 400));
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 24, bottom: 80),
                                itemCount: mesas.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 24, bottom: 16, right: 24),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.table_restaurant, color: AppTheme.secondary),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Gestión de Mesas',
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceMuted,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text('${mesas.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  final mesa = mesas[index - 1];
                                  return _buildMesaCard(context, mesa);
                                },
                              ),
                            );
                          }
                          return const Center(child: Text('Cargando mesas...', style: TextStyle(color: AppTheme.textMuted)));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            if (widget.user.recintoId == null || widget.user.recintoId!.isEmpty) return const SizedBox.shrink();
            return FloatingActionButton.extended(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<RecintoBloc>(),
                      child: CreateMesaPage(recintoId: widget.user.recintoId!),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nueva Mesa', style: TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMesaCard(BuildContext context, dynamic mesa) {
    final hasVeedor = mesa.veedorId != null;
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.how_to_vote, color: AppTheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesa ${mesa.numeroMesa}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasVeedor ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasVeedor ? Icons.check_circle : Icons.pending,
                          size: 14,
                          color: hasVeedor ? AppTheme.success : AppTheme.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasVeedor ? 'Veedor asignado' : 'Sin veedor',
                          style: TextStyle(
                            fontSize: 11,
                            color: hasVeedor ? AppTheme.success : AppTheme.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildIconButton(
                  icon: Icons.assignment_outlined,
                  color: AppTheme.primary,
                  bgColor: AppTheme.primary.withValues(alpha: 0.1),
                  tooltip: 'Ver actas',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ActasListPage(
                          mesaId: mesa.id,
                          numeroMesa: mesa.numeroMesa,
                          recintoId: widget.user.recintoId!,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildIconButton(
                  icon: hasVeedor ? Icons.edit_outlined : Icons.person_add_alt_1,
                  color: hasVeedor ? AppTheme.textMuted : AppTheme.warning,
                  bgColor: hasVeedor ? AppTheme.surfaceMuted : AppTheme.warning.withValues(alpha: 0.15),
                  tooltip: hasVeedor ? 'Reasignar veedor' : 'Asignar veedor',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<RecintoBloc>(),
                          child: CreateVeedorPage(
                            mesaId: mesa.id,
                            numeroMesa: mesa.numeroMesa,
                            recintoId: widget.user.recintoId!,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    Color? bgColor,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: bgColor ?? color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
