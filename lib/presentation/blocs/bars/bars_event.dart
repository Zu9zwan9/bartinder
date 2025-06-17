import 'package:equatable/equatable.dart';

/// Base class for all bars events
abstract class BarsEvent extends Equatable {
  const BarsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load bars
class LoadBars extends BarsEvent {
  const LoadBars();
}

/// Event to refresh bars with current location
class RefreshBars extends BarsEvent {
  const RefreshBars();
}

/// Event to like a bar
class LikeBar extends BarsEvent {
  final String barId;

  const LikeBar(this.barId);

  @override
  List<Object?> get props => [barId];
}

/// Event to dislike a bar
class DislikeBar extends BarsEvent {
  final String barId;

  const DislikeBar(this.barId);

  @override
  List<Object?> get props => [barId];
}

/// Event to check in to a bar
class CheckInBar extends BarsEvent {
  final String barId;

  const CheckInBar(this.barId);

  @override
  List<Object?> get props => [barId];
}

/// Event to view bar details
class ViewBarDetails extends BarsEvent {
  final String barId;

  const ViewBarDetails(this.barId);

  @override
  List<Object?> get props => [barId];
}
