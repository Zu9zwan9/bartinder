import '../entities/user_location.dart';
import '../repositories/user_location_repository.dart';

/// Use case for updating user's location privacy settings
class UpdateLocationPrivacyUseCase {
  final UserLocationRepository _repository;

  UpdateLocationPrivacyUseCase(this._repository);

  /// Execute the use case to update location privacy
  Future<void> execute(String userId, LocationPrivacyLevel privacyLevel) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    await _repository.updateLocationPrivacy(userId, privacyLevel);
  }
}
