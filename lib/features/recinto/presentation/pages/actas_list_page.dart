import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../veedor/domain/entities/acta_entity.dart';
import '../../../veedor/presentation/bloc/veedor_bloc.dart';
import '../../../veedor/presentation/bloc/veedor_event.dart';
import '../../../veedor/presentation/bloc/veedor_state.dart';
import '../../../veedor/presentation/pages/acta_form_page.dart';

class ActasListPage extends StatelessWidget {
  final String mesaId;
  final String numeroMesa;
  final String recintoId;

  const ActasListPage({
    super.key,
    required this.mesaId,
    required this.numeroMesa,
    required this.recintoId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.sl<VeedorBloc>()..add(LoadActasByMesaEvent(mesaId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Actas - Mesa $numeroMesa'),
          actions: [
            IconButton(
              tooltip: 'Recargar',
              icon: const Icon(Icons.refresh),
              onPressed: () => context
                  .read<VeedorBloc>()
                  .add(LoadActasByMesaEvent(mesaId)),
            ),
          ],
        ),
        body: BlocBuilder<VeedorBloc, VeedorState>(
          builder: (context, state) {
            if (state is VeedorLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VeedorError) {
              return _buildError(context, state.message);
            }
            if (state is VeedorActasListLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<VeedorBloc>()
                      .add(LoadActasByMesaEvent(mesaId));
                  await Future<void>.delayed(
                      const Duration(milliseconds: 400));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHeaderInfo(context, state.actas),
                    const SizedBox(height: 16),
                    _buildActaCard(
                      context: context,
                      dignidad: 'Alcalde',
                      acta: _findActa(state.actas, 'Alcalde'),
                    ),
                    const SizedBox(height: 16),
                    _buildActaCard(
                      context: context,
                      dignidad: 'Prefecto',
                      acta: _findActa(state.actas, 'Prefecto'),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Como Coordinador de Recinto, puede tocar un acta '
                      'subida para ver o corregir sus datos y/o foto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Cargando...'));
          },
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, List<ActaEntity> actas) {
    final totalSubidas = actas.length;
    final porcentaje = (totalSubidas / 2) * 100;
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mesa $numeroMesa  ·  Recinto $recintoId',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalSubidas / 2,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: totalSubidas == 2 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalSubidas de 2 actas subidas  ·  ${porcentaje.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  ActaEntity? _findActa(List<ActaEntity> actas, String dignidad) {
    try {
      return actas.firstWhere((a) => a.tipoActa == dignidad);
    } catch (_) {
      return null;
    }
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text('Error al cargar las actas:\n$message',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: () => context
                  .read<VeedorBloc>()
                  .add(LoadActasByMesaEvent(mesaId)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActaCard({
    required BuildContext context,
    required String dignidad,
    required ActaEntity? acta,
  }) {
    final isSubida = acta != null;
    final colorPrincipal = isSubida ? Colors.green : Colors.orange;
    final icono = isSubida ? Icons.check_circle : Icons.pending_actions;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isSubida ? () => _abrirFormularioEdicion(context, dignidad, acta) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icono, color: colorPrincipal, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Acta de $dignidad',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorPrincipal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isSubida ? 'SUBIDA' : 'PENDIENTE',
                      style: TextStyle(
                        color: colorPrincipal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              if (isSubida) ...[
                _buildInfoRow(
                    Icons.how_to_vote, 'Sufragantes: ${acta.totalSufragantes}'),
                _buildInfoRow(Icons.ballot_outlined,
                    'Candidatos: ${acta.votosCandidato1 + acta.votosCandidato2 + acta.votosCandidato3 + acta.votosCandidato4 + acta.votosCandidato5}'),
                _buildInfoRow(Icons.do_not_disturb_alt,
                    'Blancos: ${acta.votosBlancos}  ·  Nulos: ${acta.votosNulos}'),
                _buildInfoRow(Icons.location_on,
                    'GPS: ${acta.latitud.toStringAsFixed(5)}, ${acta.longitud.toStringAsFixed(5)}'),
                if (acta.novedades.isNotEmpty)
                  _buildInfoRow(Icons.note, 'Novedades: ${acta.novedades}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      isSubida
                          ? 'Tocar para ver / editar'
                          : 'Sin acta registrada',
                      style: TextStyle(
                        color: isSubida ? Colors.blue : Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isSubida ? Icons.chevron_right : Icons.lock_outline,
                      color: isSubida ? Colors.blue : Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'El veedor aún no ha subido el acta de esta dignidad. '
                    'No se puede editar hasta que sea registrada.',
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _abrirFormularioEdicion(
      BuildContext context, String dignidad, ActaEntity acta) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<VeedorBloc>.value(
          value: context.read<VeedorBloc>(),
          child: ActaFormPage(
            mesaId: mesaId,
            recintoId: recintoId,
            tipoActa: dignidad,
            actaExistente: acta,
          ),
        ),
      ),
    );
    if (context.mounted) {
      context.read<VeedorBloc>().add(LoadActasByMesaEvent(mesaId));
    }
  }
}
