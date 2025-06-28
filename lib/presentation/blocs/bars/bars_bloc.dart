import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/bar_repository_impl.dart';
import '../../../data/repositories/user_location_repository_impl.dart';
import '../../../data/services/geolocation_service.dart';
import '../../../domain/entities/user_location.dart';
import '../../../domain/repositories/user_location_repository.dart';
import '../../../domain/usecases/check_in_bar_usecase.dart';
import '../../../domain/usecases/dislike_bar_usecase.dart';
import '../../../domain/usecases/get_bar_by_id_usecase.dart';
import '../../../domain/usecases/get_bars_usecase.dart';
import '../../../domain/usecases/like_bar_usecase.dart';
import '../../../domain/usecases/save_user_location_usecase.dart';
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
  final SaveUserLocationUseCase _saveUserLocationUseCase;

  BarsBloc({
    required GetBarsUseCase getBarsUseCase,
    required GetBarByIdUseCase getBarByIdUseCase,
    required LikeBarUseCase likeBarUseCase,
    required DislikeBarUseCase dislikeBarUseCase,
    required CheckInBarUseCase checkInBarUseCase,
    required GeolocationService geolocationService,
    required BarRepositoryImpl barRepository,
    required SaveUserLocationUseCase saveUserLocationUseCase,
  }) : _getBarsUseCase = getBarsUseCase,
       _getBarByIdUseCase = getBarByIdUseCase,
       _likeBarUseCase = likeBarUseCase,
       _dislikeBarUseCase = dislikeBarUseCase,
       _checkInBarUseCase = checkInBarUseCase,
       _geolocationService = geolocationService,
       _barRepository = barRepository,
       _saveUserLocationUseCase = saveUserLocationUseCase,
       super(const BarsInitial()) {
    on<LoadBars>(_onLoadBars);
    on<RefreshBars>(_onRefreshBars);
    on<LikeBar>(_onLikeBar);
    on<DislikeBar>(_onDislikeBar);
    on<CheckInBar>(_onCheckInBar);
    on<ViewBarDetails>(_onViewBarDetails);
    on<LoadBarsWithinDistance>(_onLoadBarsWithinDistance);
    on<UpdateDistanceFilter>(_onUpdateDistanceFilter);
    on<RefreshUserLocation>(_onRefreshUserLocation);
  }

  /// Convenience constructor with default dependencies
  factory BarsBloc.withDefaultDependencies() {
    final barRepository = BarRepositoryImpl();
    final geolocationService = GeolocationService();
    final userLocationRepository = UserLocationRepositoryImpl();

    return BarsBloc(
      getBarsUseCase: GetBarsUseCase(barRepository),
      getBarByIdUseCase: GetBarByIdUseCase(barRepository),
      likeBarUseCase: LikeBarUseCase(barRepository),
      dislikeBarUseCase: DislikeBarUseCase(barRepository),
      checkInBarUseCase: CheckInBarUseCase(barRepository),
      geolocationService: geolocationService,
      barRepository: barRepository,
      saveUserLocationUseCase: SaveUserLocationUseCase(userLocationRepository),
    );
  }

  Future<void> _onLoadBars(LoadBars event, Emitter<BarsState> emit) async {
    emit(const BarsLoading());
    try {
      // Get the current location of the user
      final Position? position = await _geolocationService.getCurrentPosition();
      if (position == null) {
        emit(BarsError('Could not get current location'));
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
        emit(BarsError('Could not get current location'));
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
        emit(BarsError('Could not get current location'));
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
    emit(DistanceFilterUpdated(event.maxDistance));

    // Automatically reload bars with the new distance filter
    add(LoadBarsWithinDistance(event.maxDistance));
  }

  Future<void> _onRefreshUserLocation(
    RefreshUserLocation event,
    Emitter<BarsState> emit,
  ) async {
    try {
      emit(const BarsLoading());

      // Get the current location of the user
      final Position? position = await _geolocationService.getCurrentPosition();
      if (position == null) {
        emit(BarsError('Could not get current location'));
        return;
      }

      // Get the current authenticated user ID
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        emit(BarsError('User not authenticated'));
        return;
      }

      // Save the location
      final userLocation = UserLocation(
        id: const Uuid().v4(), // Generate a proper UUID
        userId: currentUser.id, // Use actual authenticated user ID
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        isCurrentLocation: true, // Mark as current location
      );
      await _saveUserLocationUseCase.execute(userLocation);

      // Reload bars
      add(const LoadBars());
    } catch (e) {
      emit(BarsError('Failed to refresh user location: ${e.toString()}'));
    }
  }
}
