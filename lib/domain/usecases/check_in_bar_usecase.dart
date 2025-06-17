import '../repositories/bar_repository.dart';

/// Use case for checking in to a bar
class CheckInBarUseCase {
  final BarRepository _barRepository;

  CheckInBarUseCase(this._barRepository);

  /// Execute the use case
  Future<void> execute(String barId) async {
    await _barRepository.checkIn(barId);
  }
}
