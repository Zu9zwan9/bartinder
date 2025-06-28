import '../entities/user_location.dart';
import '../repositories/user_location_repository.dart';

/// Use case for getting user's current location
class GetCurrentUserLocationUseCase {
  final UserLocationRepository _repository;

  GetCurrentUserLocationUseCase(this._repository);

  /// Execute the use case to get user's current location
  Future<UserLocation?> execute(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _repository.getCurrentUserLocation(userId);
  }
}
