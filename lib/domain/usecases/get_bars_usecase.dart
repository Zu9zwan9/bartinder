import '../entities/bar.dart';
import '../repositories/bar_repository.dart';

/// Use case for getting a list of bars
class GetBarsUseCase {
  final BarRepository _barRepository;

  GetBarsUseCase(this._barRepository);

  /// Execute the use case
  Future<List<Bar>> execute() async {
    return await _barRepository.getBars();
  }
}
