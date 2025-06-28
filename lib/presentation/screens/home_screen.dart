import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repositories/supabase_user_repository_impl.dart';
import '../../data/repositories/location_repository.dart';
import '../../core/services/location_service.dart';
import '../../data/services/auth_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/distance_filter.dart';
import '../blocs/user_swipe/user_swipe_bloc.dart';
import '../blocs/user_swipe/user_swipe_event.dart';
import '../blocs/user_swipe/user_swipe_state.dart';
import '../theme/theme.dart';
import '../widgets/match_dialog.dart';
import '../widgets/user_card.dart';
import '../widgets/distance_filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController _cardController = CardSwiperController();
  late final UserSwipeBloc _userSwipeBloc;
  final LocationService _locationService = LocationService();

  DistanceFilter _currentDistanceFilter = DistanceFilter.inMyCity;
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _userSwipeBloc = UserSwipeBloc(
      userRepository: SupabaseUserRepositoryImpl(),
      locationRepository: LocationRepository(),
      locationService: _locationService,
    );
    _initializeLocation();
  }

  /// Initialize location and load users based on location
  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        // Load users with location filter
        _loadUsersWithLocationFilter();
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
        // Fallback to loading all users if location is not available
        _userSwipeBloc.add(const LoadUsers());
        _showLocationPermissionDialog();
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      // Fallback to loading all users
      _userSwipeBloc.add(const LoadUsers());
    }
  }

  /// Load users with current location filter
  void _loadUsersWithLocationFilter() {
    if (_currentPosition != null) {
      final currentUserId = AuthService.currentUserId;
      if (currentUserId != null) {
        _userSwipeBloc.add(LoadUsersWithLocationFilter(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          distanceFilter: _currentDistanceFilter,
          currentUserId: currentUserId,
        ));
      } else {
        // User not authenticated, show error or redirect to login
        _userSwipeBloc.add(const LoadUsers()); // Fallback to loading all users
      }
    }
  }

  /// Show distance filter sheet
  Future<void> _showDistanceFilter() async {
    final selectedFilter = await DistanceFilterSheet.show(
      context,
      _currentDistanceFilter,
    );

    if (selectedFilter != null && selectedFilter != _currentDistanceFilter) {
      setState(() {
        _currentDistanceFilter = selectedFilter;
      });
      _loadUsersWithLocationFilter();
    }
  }

  /// Show location permission dialog
  void _showLocationPermissionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Location Access'),
        content: const Text(
          'To show you people nearby, we need access to your location. '
          'You can enable this in Settings or continue without location-based matching.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Continue Without'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Try Again'),
            onPressed: () {
              Navigator.of(context).pop();
              _initializeLocation();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _userSwipeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _userSwipeBloc,
      child: CupertinoPageScaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor:
              Theme.of(context).appBarTheme.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
          middle: Text(
            'SipSwipe',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Distance filter button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _currentPosition != null ? _showDistanceFilter : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentPosition != null
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.location_fill,
                        size: 16,
                        color: _currentPosition != null
                            ? AppTheme.primaryColor
                            : Theme.of(context).disabledColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _currentDistanceFilter.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _currentPosition != null
                              ? AppTheme.primaryColor
                              : Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          border: null, // Remove the border to reduce space
        ),
        child: SafeArea(
          top: false, // Set top to false to minimize the gap at the top
          bottom: false, // Set bottom to false for manual layout control
          child: BlocConsumer<UserSwipeBloc, UserSwipeState>(
            listener: (context, state) {
              if (state is UserSwipeMatch) {
                _showMatchDialog(context, state.matchedUser);
              }
            },
            builder: (context, state) {
              // Show location loading state
              if (_isLoadingLocation) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CupertinoActivityIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Getting your location...',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }

              if (state is UserSwipeLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CupertinoActivityIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        _currentPosition != null
                            ? 'Finding people ${_currentDistanceFilter.displayName.toLowerCase()}...'
                            : 'Loading users...',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              } else if (state is UserSwipeLoaded) {
                return _buildSwipeCards(context, state.users);
              } else if (state is UserSwipeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        onPressed: () {
                          if (_currentPosition != null) {
                            _loadUsersWithLocationFilter();
                          } else {
                            _userSwipeBloc.add(const LoadUsers());
                          }
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
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

  Widget _buildSwipeCards(BuildContext context, List<User> users) {
    final hasUsers = users.isNotEmpty;
    final count = hasUsers ? users.length : 1;

    // Get accurate measurements for layout
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final navBarHeight = CupertinoNavigationBar().preferredSize.height;
    final bottomPadding = mediaQuery.padding.bottom;
    final statusBarHeight = mediaQuery.padding.top;

    // Set a fixed height for action area that ensures buttons are visible
    const actionAreaHeight = 100.0;

    // Calculate card area height with more conservative values to ensure buttons are visible
    final availableHeight =
        screenHeight - navBarHeight - statusBarHeight - bottomPadding;
    final cardAreaHeight =
        availableHeight *
        0.75; // Reduced by 30% from original 0.8 (0.8 * 0.7 = 0.56)

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
                  key: ValueKey(count),
                  controller: _cardController,
                  cardsCount: count,
                  onSwipe: hasUsers
                      ? (prev, curr, direction) {
                          final user = users[prev];
                          _userSwipeBloc.add(
                            direction == CardSwiperDirection.right
                                ? LikeUser(user)
                                : DislikeUser(user),
                          );
                          return true;
                        }
                      : (index, secondIndex, direction) => false,
                  numberOfCardsDisplayed: math.min(3, count),
                  backCardOffset: const Offset(20, 20),
                  padding: const EdgeInsets.all(16),
                  cardBuilder:
                      (context, index, horizontalOffset, verticalOffset) {
                        if (!hasUsers) {
                          return _buildNoMoreCard();
                        }
                        return UserCard(user: users[index]);
                      },
                ),
              ),
            ),

            // Space for action buttons
            SizedBox(height: actionAreaHeight),

            // Fill remaining space
            const Spacer(),
          ],
        ),

        // Action area positioned below the cards
        Positioned(
          bottom:
              bottomPadding +
              45, // Position higher with more padding from bottom
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
                // Dislike button (left)
                Expanded(
                  child: _buildActionButton(
                    icon: CupertinoIcons.xmark_circle_fill,
                    color: Theme.of(context).colorScheme.error,
                    onTap: () {
                      if (hasUsers) {
                        _cardController.swipe(CardSwiperDirection.left);
                      } else {
                        _userSwipeBloc.add(const LoadUsers());
                      }
                    },
                  ),
                ),

                const SizedBox(width: 32), // Consistent space between buttons
                // Like button (right)
                Expanded(
                  child: _buildActionButton(
                    icon: CupertinoIcons.heart_fill,
                    color: Colors.green,
                    onTap: () {
                      if (hasUsers) {
                        _cardController.swipe(CardSwiperDirection.right);
                      } else {
                        _userSwipeBloc.add(const LoadUsers());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoMoreCard() {
    final String message = _currentPosition != null
        ? 'No more beer buddies ${_currentDistanceFilter.displayName.toLowerCase()}'
        : 'No more beer buddies nearby';

    final String subtitle = _currentPosition != null
        ? 'Try expanding your distance or check back later'
        : 'Enable location to find people nearby';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _currentPosition != null
                  ? CupertinoIcons.location_circle
                  : CupertinoIcons.person_2_fill,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentPosition != null) ...[
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    onPressed: _showDistanceFilter,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.slider_horizontal_3, size: 16, color: CupertinoColors.black),
                        const SizedBox(width: 8),
                        const Text('Change Filter', style: TextStyle(fontSize: 14, color: CupertinoColors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: () {
                    if (_currentPosition != null) {
                      _loadUsersWithLocationFilter();
                    } else {
                      _initializeLocation();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.refresh,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
          color: Theme.of(context).cardColor,
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

  void _showMatchDialog(BuildContext context, User matchedUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MatchDialog(
        matchedUser: matchedUser,
        onContinue: () => Navigator.of(ctx).pop(),
        onMessage: () {
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Messaging feature coming soon!')),
          );
        },
      ),
    );
  }
}
