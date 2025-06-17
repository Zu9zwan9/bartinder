import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/repositories/bar_repository_impl.dart';
import '../../../data/services/geolocation_service.dart';
import '../../../domain/entities/bar.dart';
import '../../../domain/usecases/check_in_bar_usecase.dart';
import '../../../domain/usecases/dislike_bar_usecase.dart';
import '../../../domain/usecases/get_bar_by_id_usecase.dart';
import '../../../domain/usecases/get_bars_usecase.dart';
import '../../../domain/usecases/like_bar_usecase.dart';
import 'bars_event.dart';
import 'bars_state.dart';

/// BLoC for the Bars page
class BarsBloc extends Bloc<BarsEvent, BarsState> {
  final GetBarsUseCase _getBarsUseCase;
  final GetBarByIdUseCase _getBarByIdUseCase;
  final LikeBarUseCase _likeBarUseCase;
  final DislikeBarUseCase _dislikeBarUseCase;
  final CheckInBarUseCase _checkInBarUseCase;
  final GeolocationService _geolocationService;

  BarsBloc({
    required GetBarsUseCase getBarsUseCase,
    required GetBarByIdUseCase getBarByIdUseCase,
    required LikeBarUseCase likeBarUseCase,
    required DislikeBarUseCase dislikeBarUseCase,
    required CheckInBarUseCase checkInBarUseCase,
    required GeolocationService geolocationService,
  })  : _getBarsUseCase = getBarsUseCase,
        _getBarByIdUseCase = getBarByIdUseCase,
        _likeBarUseCase = likeBarUseCase,
        _dislikeBarUseCase = dislikeBarUseCase,
        _checkInBarUseCase = checkInBarUseCase,
        _geolocationService = geolocationService,
        super(const BarsInitial()) {
    on<LoadBars>(_onLoadBars);
    on<RefreshBars>(_onRefreshBars);
    on<LikeBar>(_onLikeBar);
    on<DislikeBar>(_onDislikeBar);
    on<CheckInBar>(_onCheckInBar);
    on<ViewBarDetails>(_onViewBarDetails);
  }

  /// Convenience constructor with default dependencies
  factory BarsBloc.withDefaultDependencies() {
    final barRepository = BarRepositoryImpl();
    final geolocationService = GeolocationService();

    return BarsBloc(
      getBarsUseCase: GetBarsUseCase(barRepository),
      getBarByIdUseCase: GetBarByIdUseCase(barRepository),
      likeBarUseCase: LikeBarUseCase(barRepository),
      dislikeBarUseCase: DislikeBarUseCase(barRepository),
      checkInBarUseCase: CheckInBarUseCase(barRepository),
      geolocationService: geolocationService,
    );
  }

  Future<void> _onLoadBars(LoadBars event, Emitter<BarsState> emit) async {
    emit(const BarsLoading());
    try {
      // Check location services and permissions
      final serviceEnabled = await _geolocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const LocationServicesDisabled());
        return;
      }

      final permission = await _geolocationService.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(const LocationPermissionDenied());
        return;
      }

      // Get bars
      final bars = await _getBarsUseCase.execute();
      emit(BarsLoaded(bars));
    } catch (e) {
      emit(BarsError('Failed to load bars: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshBars(RefreshBars event, Emitter<BarsState> emit) async {
    try {
      // Get current position
      final position = await _geolocationService.getCurrentPosition();
      if (position == null) {
        emit(const BarsError('Could not get current location'));
        return;
      }

      // Get bars
      final bars = await _getBarsUseCase.execute();

      // TODO In a real app, we would update the distances based on the current position
      // For now, we'll just return the bars as they are
      emit(BarsLoaded(bars));
    } catch (e) {
      emit(BarsError('Failed to refresh bars: ${e.toString()}'));
    }
  }

  Future<void> _onLikeBar(LikeBar event, Emitter<BarsState> emit) async {
    try {
      await _likeBarUseCase.execute(event.barId);

      // Refresh the bars list
      add(const LoadBars());
    } catch (e) {
      emit(BarsError('Failed to like bar: ${e.toString()}'));
    }
  }

  Future<void> _onDislikeBar(DislikeBar event, Emitter<BarsState> emit) async {
    try {
      await _dislikeBarUseCase.execute(event.barId);

      // Refresh the bars list
      add(const LoadBars());
    } catch (e) {
      emit(BarsError('Failed to dislike bar: ${e.toString()}'));
    }
  }

  Future<void> _onCheckInBar(CheckInBar event, Emitter<BarsState> emit) async {
    try {
      await _checkInBarUseCase.execute(event.barId);

      // Get the bar name for the success message
      final bar = await _getBarByIdUseCase.execute(event.barId);
      if (bar != null) {
        emit(CheckInSuccess(event.barId, bar.name));
      }

      // Refresh the bars list
      add(const LoadBars());
    } catch (e) {
      emit(BarsError('Failed to check in: ${e.toString()}'));
    }
  }

  Future<void> _onViewBarDetails(ViewBarDetails event, Emitter<BarsState> emit) async {
    try {
      final bar = await _getBarByIdUseCase.execute(event.barId);
      if (bar != null) {
        emit(BarDetailsLoaded(bar));
      } else {
        emit(const BarsError('Bar not found'));
      }
    } catch (e) {
      emit(BarsError('Failed to load bar details: ${e.toString()}'));
    }
  }
}
