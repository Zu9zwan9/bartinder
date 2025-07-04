import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/services/location_service.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/entities/distance_filter.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService locationService;
  final LocationRepository locationRepository;
  final String userId;

  LocationBloc({
    required this.locationService,
    required this.locationRepository,
    required this.userId,
  }) : super(LocationInitial()) {
    on<GetAndSaveLocationEvent>(_onGetAndSaveLocation);
    on<FindUsersNearbyEvent>(_onFindUsersNearby);
    on<FindUsersByDistanceFilterEvent>(_onFindUsersByDistanceFilter);
  }

  Future<void> _onGetAndSaveLocation(
    GetAndSaveLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final position = await locationService.getCurrentLocation();
    if (position == null) {
      emit(LocationError('Не удалось получить геолокацию'));
      return;
    }
    await locationRepository.saveUserLocation(
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
    );
    emit(LocationLoaded(position: position));
  }

  Future<void> _onFindUsersNearby(
    FindUsersNearbyEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final users = await locationRepository.getUsersNearby(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusInKm: event.radiusInKm,
    );
    emit(UsersNearbyLoaded(users));
  }

  Future<void> _onFindUsersByDistanceFilter(
    FindUsersByDistanceFilterEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      final users = await locationRepository.getUsersByDistanceFilter(
        latitude: event.latitude,
        longitude: event.longitude,
        distanceFilter: event.distanceFilter,
        excludeUserId: userId,
      );
      emit(UsersNearbyLoaded(users));
    } catch (e) {
      emit(LocationError('Не удалось найти пользователей: ${e.toString()}'));
    }
  }
}
