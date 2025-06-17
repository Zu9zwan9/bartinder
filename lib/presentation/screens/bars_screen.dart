import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../domain/entities/bar.dart';
import '../blocs/bars/bars_bloc.dart';
import '../blocs/bars/bars_event.dart';
import '../blocs/bars/bars_state.dart';
import '../theme/theme.dart';
import '../widgets/bar_card.dart';
import '../widgets/bar_detail_screen.dart';
import '../widgets/heading_users_list.dart';

/// Screen for displaying and interacting with bars
class BarsScreen extends StatefulWidget {
  const BarsScreen({super.key});

  @override
  State<BarsScreen> createState() => _BarsScreenState();
}

class _BarsScreenState extends State<BarsScreen> {
  final CardSwiperController _cardController = CardSwiperController();
  late final BarsBloc _barsBloc;

  @override
  void initState() {
    super.initState();
    _barsBloc = BarsBloc.withDefaultDependencies()
      ..add(const LoadBars());
  }

  @override
  void dispose() {
    _cardController.dispose();
    _barsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _barsBloc,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Discover Bars'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.refresh),
            onPressed: () => _barsBloc.add(const RefreshBars()),
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<BarsBloc, BarsState>(
            listener: (context, state) {
              if (state is BarDetailsLoaded) {
                _showBarDetails(context, state.bar);
              } else if (state is CheckInSuccess) {
                _showCheckInSuccess(context, state.barName);
              } else if (state is LocationServicesDisabled) {
                _showLocationServicesDisabledDialog(context);
              } else if (state is LocationPermissionDenied) {
                _showLocationPermissionDeniedDialog(context);
              }
            },
            builder: (context, state) {
              if (state is BarsLoading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state is BarsLoaded) {
                return state.bars.isEmpty
                    ? _buildEmptyState()
                    : _buildBarsList(context, state.bars);
              } else if (state is BarsError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.errorColor,
                    ),
                  ),
                );
              }
              return const Center(child: CupertinoActivityIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarsList(BuildContext context, List<Bar> bars) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CardSwiper(
              controller: _cardController,
              cardsCount: bars.length,
              onSwipe: (prev, curr, dir) {
                final bar = bars[prev];
                _barsBloc.add(
                  dir == CardSwiperDirection.right
                      ? LikeBar(bar.id)
                      : DislikeBar(bar.id),
                );
                return true;
              },
              numberOfCardsDisplayed: 3,
              backCardOffset: const Offset(20, 20),
              padding: const EdgeInsets.all(24),
              cardBuilder: (context, index, horizontalOffset, verticalOffset) {
                return BarCard(
                  bar: bars[index],
                  onTap: () => _barsBloc.add(ViewBarDetails(bars[index].id)),
                );
              },
            ),
          ),
        ),
        if (bars.isNotEmpty && bars[0].usersHeadingThere.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'People heading to ${bars[0].name}:',
                  style: AppTheme.subtitleStyle,
                ),
                const SizedBox(height: 8),
                HeadingUsersList(userIds: bars[0].usersHeadingThere),
                const SizedBox(height: 16),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: CupertinoIcons.xmark_circle_fill,
                color: AppTheme.errorColor,
                onTap: () => _cardController.swipe(CardSwiperDirection.left),
              ),
              _buildActionButton(
                icon: CupertinoIcons.heart_fill,
                color: AppTheme.successColor,
                onTap: () => _cardController.swipe(CardSwiperDirection.right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.map_fill,
            size: 80,
            color: AppTheme.primaryColor.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text('No bars found nearby', style: AppTheme.titleStyle),
          const SizedBox(height: 8),
          Text(
            'Try expanding your search radius or check back later',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppTheme.primaryColor,
            onPressed: () => _barsBloc.add(const RefreshBars()),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _showBarDetails(BuildContext context, Bar bar) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => BarDetailScreen(
          bar: bar,
          onCheckIn: () {
            _barsBloc.add(CheckInBar(bar.id));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showCheckInSuccess(BuildContext context, String barName) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Check-in Successful'),
        content: Text('You have checked in to $barName'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showLocationServicesDisabledDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services in your device settings to see bars near you.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showLocationPermissionDeniedDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
          'Please grant location permission to see bars near you.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
