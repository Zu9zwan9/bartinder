import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/repositories/bar_repository_impl.dart';
import '../../../data/services/geolocation_service.dart';
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
  final BarRepositoryImpl _barRepository;

  BarsBloc({
    required GetBarsUseCase getBarsUseCase,
    required GetBarByIdUseCase getBarByIdUseCase,
    required LikeBarUseCase likeBarUseCase,
    required DislikeBarUseCase dislikeBarUseCase,
    required CheckInBarUseCase checkInBarUseCase,
    required GeolocationService geolocationService,
    required BarRepositoryImpl barRepository,
  }) : _getBarsUseCase = getBarsUseCase,
       _getBarByIdUseCase = getBarByIdUseCase,
       _likeBarUseCase = likeBarUseCase,
       _dislikeBarUseCase = dislikeBarUseCase,
       _checkInBarUseCase = checkInBarUseCase,
       _geolocationService = geolocationService,
       _barRepository = barRepository,
       super(const BarsInitial()) {
    on<LoadBars>(_onLoadBars);
    on<RefreshBars>(_onRefreshBars);
    on<LikeBar>(_onLikeBar);
    on<DislikeBar>(_onDislikeBar);
    on<CheckInBar>(_onCheckInBar);
    on<ViewBarDetails>(_onViewBarDetails);
    on<LoadBarsWithinDistance>(_onLoadBarsWithinDistance);
    on<UpdateDistanceFilter>(_onUpdateDistanceFilter);
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
      barRepository: barRepository,
    );
  }

  Future<void> _onLoadBars(LoadBars event, Emitter<BarsState> emit) async {
    emit(const BarsLoading());
    try {
      // Get the current location of the user
      final Position? position = await _geolocationService.getCurrentPosition();
      if (position == null) {
        emit(const BarsError('Could not get current location'));
        return;
      }

      // Fetch the list of bars
      final bars = await _getBarsUseCase.execute();

      // Calculate the distance to each bar dynamically
      final barsWithDistance = bars.map((bar) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          bar.latitude,
          bar.longitude,
        ) / 1000; // Convert meters to kilometers
        return bar.copyWith(distance: distance);
      }).toList();

      emit(BarsLoaded(barsWithDistance)); // Pass the updated list of bars
    } catch (e) {
      emit(BarsError('Failed to load bars: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshBars(
    RefreshBars event,
    Emitter<BarsState> emit,
  ) async {
    try {
      // Get current position
      final position = await _geolocationService.getCurrentPosition();
      if (position == null) {
        emit(const BarsError('Could not get current location'));
        return;
      }

      // Get bars and calculate distances based on current position
      final bars = await _getBarsUseCase.execute();

      // Calculate the distance to each bar dynamically
      final barsWithDistance = bars.map((bar) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          bar.latitude,
          bar.longitude,
        ) / 1000; // Convert meters to kilometers
        return bar.copyWith(distance: distance);
      }).toList();

      emit(BarsLoaded(barsWithDistance));
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

  Future<void> _onViewBarDetails(
    ViewBarDetails event,
    Emitter<BarsState> emit,
  ) async {
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

  Future<void> _onLoadBarsWithinDistance(
    LoadBarsWithinDistance event,
    Emitter<BarsState> emit,
  ) async {
    emit(const BarsLoading());
    try {
      // Get the current location of the user
      final Position? position = await _geolocationService.getCurrentPosition();
      if (position == null) {
        emit(const BarsError('Could not get current location'));
        return;
      }

      // Get bars within the specified distance using the repository method
      final bars = await _barRepository.getBarsWithinDistance(
        userLatitude: position.latitude,
        userLongitude: position.longitude,
        maxDistanceKm: event.maxDistanceKm,
      );

      emit(BarsLoadedWithDistance(bars, event.maxDistanceKm));
    } catch (e) {
      emit(BarsError('Failed to load bars within distance: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDistanceFilter(
    UpdateDistanceFilter event,
    Emitter<BarsState> emit,
  ) async {
    // Update the distance filter and reload bars
    emit(DistanceFilterUpdated(event.maxDistanceKm));

    // Automatically reload bars with the new distance filter
    add(LoadBarsWithinDistance(event.maxDistanceKm));
  }
}
