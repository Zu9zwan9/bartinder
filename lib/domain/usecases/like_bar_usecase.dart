import '../repositories/bar_repository.dart';

/// Use case for liking a bar
class LikeBarUseCase {
  final BarRepository _barRepository;

  LikeBarUseCase(this._barRepository);

  /// Execute the use case
  Future<void> execute(String barId) async {
    await _barRepository.likeBar(barId);
  }
}
