import 'package:equatable/equatable.dart';
import '../../domain/entities/recinto_entity.dart';

abstract class ProvincialState extends Equatable {
  const ProvincialState();

  @override
  List<Object?> get props => [];
}

class ProvincialInitial extends ProvincialState {}

class ProvincialLoading extends ProvincialState {}

class ProvincialRecintosLoaded extends ProvincialState {
  final List<RecintoEntity> recintos;

  const ProvincialRecintosLoaded(this.recintos);

  @override
  List<Object?> get props => [recintos];
}

class ProvincialActionSuccess extends ProvincialState {
  final String message;

  const ProvincialActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProvincialError extends ProvincialState {
  final String message;

  const ProvincialError(this.message);

  @override
  List<Object?> get props => [message];
}
