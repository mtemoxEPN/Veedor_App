import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_acta_mesa_usecase.dart';
import '../../domain/usecases/get_actas_by_mesa_usecase.dart';
import '../../domain/usecases/get_mesas_by_veedor_usecase.dart';
import '../../domain/usecases/submit_acta_usecase.dart';
import 'veedor_event.dart';
import 'veedor_state.dart';

class VeedorBloc extends Bloc<VeedorEvent, VeedorState> {
  final GetActaMesaUseCase getActaMesaUseCase;
  final GetActasByMesaUseCase getActasByMesaUseCase;
  final GetMesasByVeedorUseCase getMesasByVeedorUseCase;
  final SubmitActaUseCase submitActaUseCase;

  VeedorBloc({
    required this.getActaMesaUseCase,
    required this.getActasByMesaUseCase,
    required this.getMesasByVeedorUseCase,
    required this.submitActaUseCase,
  }) : super(VeedorInitial()) {
    on<CheckActaStatusEvent>(_onCheckActaStatus);
    on<LoadActasByMesaEvent>(_onLoadActasByMesa);
    on<LoadMesasByVeedorEvent>(_onLoadMesasByVeedor);
    on<SubmitActaEvent>(_onSubmitActa);
  }

  Future<void> _onCheckActaStatus(CheckActaStatusEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await getActaMesaUseCase(event.mesaId, event.tipoActa);
    result.fold(
      (failure) => emit(VeedorError(failure.message)),
      (acta) => emit(VeedorActaStatus(acta)),
    );
  }

  Future<void> _onLoadActasByMesa(LoadActasByMesaEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await getActasByMesaUseCase(event.mesaId);
    result.fold(
      (failure) => emit(VeedorError(failure.message)),
      (actas) => emit(VeedorActasListLoaded(actas)),
    );
  }

  Future<void> _onLoadMesasByVeedor(LoadMesasByVeedorEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await getMesasByVeedorUseCase(event.veedorId);
    result.fold(
      (failure) => emit(VeedorError(failure.message)),
      (mesas) => emit(VeedorMesasListLoaded(mesas)),
    );
  }

  Future<void> _onSubmitActa(SubmitActaEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await submitActaUseCase(
      mesaId: event.mesaId,
      recintoId: event.recintoId,
      tipoActa: event.tipoActa,
      novedades: event.novedades,
      imagePath: event.imagePath,
      votosCandidato1: event.votosCandidato1,
      votosCandidato2: event.votosCandidato2,
      votosCandidato3: event.votosCandidato3,
      votosCandidato4: event.votosCandidato4,
      votosCandidato5: event.votosCandidato5,
      votosBlancos: event.votosBlancos,
      votosNulos: event.votosNulos,
      totalSufragantes: event.totalSufragantes,
      latitud: event.latitud,
      longitud: event.longitud,
    );
    result.fold(
      (failure) => emit(VeedorError(failure.message)),
      (acta) => emit(VeedorActaSubmittedSuccess(acta)),
    );
  }
}
