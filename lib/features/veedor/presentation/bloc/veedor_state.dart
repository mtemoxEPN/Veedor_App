import 'package:equatable/equatable.dart';
import '../../domain/entities/acta_entity.dart';
import '../../../recinto/domain/entities/mesa_entity.dart';

abstract class VeedorState extends Equatable {
  const VeedorState();

  @override
  List<Object?> get props => [];
}

class VeedorInitial extends VeedorState {}

class VeedorLoading extends VeedorState {}

class VeedorActaStatus extends VeedorState {
  final ActaEntity? acta; // Si es null, no ha reportado. Si tiene datos, ya reportó.

  const VeedorActaStatus(this.acta);

  @override
  List<Object?> get props => [acta];
}

class VeedorActaSubmittedSuccess extends VeedorState {
  final ActaEntity acta;

  const VeedorActaSubmittedSuccess(this.acta);

  @override
  List<Object?> get props => [acta];
}

class VeedorError extends VeedorState {
  final String message;

  const VeedorError(this.message);

  @override
  List<Object?> get props => [message];
}

class VeedorActasListLoaded extends VeedorState {
  final List<ActaEntity> actas;

  const VeedorActasListLoaded(this.actas);

  @override
  List<Object?> get props => [actas];
}

class VeedorMesasListLoaded extends VeedorState {
  final List<MesaEntity> mesas;

  const VeedorMesasListLoaded(this.mesas);

  @override
  List<Object?> get props => [mesas];
}
