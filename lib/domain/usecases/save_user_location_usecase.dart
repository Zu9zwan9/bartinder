import '../entities/user_location.dart';
import '../repositories/user_location_repository.dart';

/// Use case for saving user location
class SaveUserLocationUseCase {
  final UserLocationRepository _repository;

  SaveUserLocationUseCase(this._repository);

  /// Execute the use case to save user location
  Future<void> execute(UserLocation location) async {
    // Validate location data
    if (location.userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (location.latitude < -90 || location.latitude > 90) {
      throw ArgumentError('Invalid latitude: ${location.latitude}');
    }

    if (location.longitude < -180 || location.longitude > 180) {
      throw ArgumentError('Invalid longitude: ${location.longitude}');
    }

    // Save the location
    await _repository.saveUserLocation(location);
  }
}
