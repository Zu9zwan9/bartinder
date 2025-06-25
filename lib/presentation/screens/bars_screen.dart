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
    _barsBloc = BarsBloc.withDefaultDependencies()..add(const LoadBars());
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
        backgroundColor: AppTheme.backgroundColor(context),
        navigationBar: CupertinoNavigationBar(
          backgroundColor: AppTheme.isDarkMode(context)
              ? AppTheme.darkCardColor
              : Colors.white,
          middle: Text(
            'Discover Bars',
            style: AppTheme.titleStyle.copyWith(
              color: AppTheme.textColor(context),
            ),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.refresh, color: AppTheme.primaryColor),
            onPressed: () => _barsBloc.add(const RefreshBars()),
          ),
          border: null, // Remove border to reduce space
        ),
        child: SafeArea(
          top: false, // Minimize gap at top
          bottom: false, // For manual layout control
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
                return Center(
                  child: CupertinoActivityIndicator(
                    color: AppTheme.isDarkMode(context)
                        ? AppTheme.primaryColor
                        : AppTheme.primaryDarkColor,
                  ),
                );
              } else if (state is BarsLoaded) {
                return state.bars.isEmpty
                    ? _buildEmptyState()
                    : _buildBarsList(context, state.bars);
              } else if (state is BarsError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.errorColor(context),
                    ),
                  ),
                );
              }
              return Center(
                child: CupertinoActivityIndicator(
                  color: AppTheme.isDarkMode(context)
                      ? AppTheme.primaryColor
                      : AppTheme.primaryDarkColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarsList(BuildContext context, List<Bar> bars) {
    // Calculate safe layout dimensions
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final navBarHeight = CupertinoNavigationBar().preferredSize.height;
    final bottomPadding = mediaQuery.padding.bottom;
    final statusBarHeight = mediaQuery.padding.top;

    // Fixed height for action area - matches HomeScreen
    const actionAreaHeight = 100.0;

    // Calculate the space needed for the heading users section
    final bool hasHeadingUsers =
        bars.isNotEmpty && bars[0].usersHeadingThere.isNotEmpty;
    final headingUsersHeight = hasHeadingUsers ? 80.0 : 0.0;

    // Calculate card area height with more conservative values
    final availableHeight =
        screenHeight - navBarHeight - statusBarHeight - bottomPadding;
    final cardAreaHeight =
        (availableHeight * 0.8) -
        headingUsersHeight; // 80% of available height minus heading

    return Stack(
      children: [
        Column(
          children: [
            // Card swiper section with calculated height
            SizedBox(
              height: cardAreaHeight,
              width: screenWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  padding: const EdgeInsets.all(16),
                  cardBuilder:
                      (context, index, horizontalOffset, verticalOffset) {
                        return BarCard(
                          bar: bars[index],
                          onTap: () =>
                              _barsBloc.add(ViewBarDetails(bars[index].id)),
                        );
                      },
                ),
              ),
            ),

            // Heading users section if applicable
            if (hasHeadingUsers)
              SizedBox(
                height: headingUsersHeight,
                width: screenWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'People heading to ${bars[0].name}:',
                        style: AppTheme.subtitleStyle.copyWith(
                          color: AppTheme.textColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 54, // Reduced height to fit properly
                        child: HeadingUsersList(
                          userIds: bars[0].usersHeadingThere,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Spacer to push content up
            const Spacer(),
          ],
        ),

        // Action buttons section positioned at bottom of screen
        Positioned(
          bottom: bottomPadding + 45, // Moved buttons 20 pixels up
          left: 0,
          right: 0,
          child: Container(
            height: actionAreaHeight,
            width: screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Dislike button
                Expanded(
                  child: _buildActionButton(
                    icon: CupertinoIcons.xmark_circle_fill,
                    color: AppTheme.errorColor(context),
                    onTap: () =>
                        _cardController.swipe(CardSwiperDirection.left),
                  ),
                ),

                const SizedBox(
                  width: 32,
                ), // Same space as HomeScreen for consistency
                // Like button
                Expanded(
                  child: _buildActionButton(
                    icon: CupertinoIcons.heart_fill,
                    color: AppTheme.successColor(context),
                    onTap: () =>
                        _cardController.swipe(CardSwiperDirection.right),
                  ),
                ),
              ],
            ),
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
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.isDarkMode(context)
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 36),
        ),
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
          Text(
            'No bars found nearby',
            style: AppTheme.titleStyle.copyWith(
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try expanding your search radius or check back later',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.secondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppTheme.primaryColor,
            onPressed: () => _barsBloc.add(const RefreshBars()),
            child: Text(
              'Refresh',
              style: AppTheme.buttonStyle.copyWith(color: Colors.white),
            ),
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
        title: Text(
          'Check-in Successful',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'You have checked in to $barName',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
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
        title: Text(
          'Location Services Disabled',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'Please enable location services in your device settings to see bars near you.',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
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
        title: Text(
          'Location Permission Denied',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'Please grant location permission to see bars near you.',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
