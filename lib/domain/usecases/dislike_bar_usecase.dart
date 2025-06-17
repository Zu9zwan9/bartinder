import '../repositories/bar_repository.dart';

/// Use case for disliking a bar
class DislikeBarUseCase {
  final BarRepository _barRepository;

  DislikeBarUseCase(this._barRepository);

  /// Execute the use case
  Future<void> execute(String barId) async {
    await _barRepository.dislikeBar(barId);
  }
}
