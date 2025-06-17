import 'package:equatable/equatable.dart';

import '../../../domain/entities/bar.dart';

/// Base class for all bars states
abstract class BarsState extends Equatable {
  const BarsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BarsInitial extends BarsState {
  const BarsInitial();
}

/// Loading state
class BarsLoading extends BarsState {
  const BarsLoading();
}

/// Loaded state with bars
class BarsLoaded extends BarsState {
  final List<Bar> bars;

  const BarsLoaded(this.bars);

  @override
  List<Object?> get props => [bars];
}

/// Error state
class BarsError extends BarsState {
  final String message;

  const BarsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Bar details loaded state
class BarDetailsLoaded extends BarsState {
  final Bar bar;

  const BarDetailsLoaded(this.bar);

  @override
  List<Object?> get props => [bar];
}

/// Check-in success state
class CheckInSuccess extends BarsState {
  final String barId;
  final String barName;

  const CheckInSuccess(this.barId, this.barName);

  @override
  List<Object?> get props => [barId, barName];
}

/// Location permission denied state
class LocationPermissionDenied extends BarsState {
  const LocationPermissionDenied();
}

/// Location services disabled state
class LocationServicesDisabled extends BarsState {
  const LocationServicesDisabled();
}
