import '../entities/bar.dart';
import '../repositories/bar_repository.dart';

/// Use case for getting a bar by ID
class GetBarByIdUseCase {
  final BarRepository _barRepository;

  GetBarByIdUseCase(this._barRepository);

  /// Execute the use case
  Future<Bar?> execute(String barId) async {
    return await _barRepository.getBarById(barId);
  }
}
