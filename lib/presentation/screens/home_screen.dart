import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../data/repositories/supabase_user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../blocs/user_swipe/user_swipe_bloc.dart';
import '../blocs/user_swipe/user_swipe_event.dart';
import '../blocs/user_swipe/user_swipe_state.dart';
import '../theme/theme.dart';
import '../widgets/match_dialog.dart';
import '../widgets/user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController _cardController = CardSwiperController();
  late final UserSwipeBloc _userSwipeBloc;

  @override
  void initState() {
    super.initState();
    _userSwipeBloc = UserSwipeBloc(userRepository: SupabaseUserRepositoryImpl())
      ..add(const LoadUsers());
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
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
          middle: Text(
            'Beer Tinder',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
            ),
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
              if (state is UserSwipeLoading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state is UserSwipeLoaded) {
                return _buildSwipeCards(context, state.users);
              } else if (state is UserSwipeError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
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
    final availableHeight = screenHeight - navBarHeight - statusBarHeight - bottomPadding;
    final cardAreaHeight = availableHeight * 0.75; // Reduced by 30% from original 0.8 (0.8 * 0.7 = 0.56)

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
                  cardBuilder: (context, index, horizontalOffset, verticalOffset) {
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
          bottom: bottomPadding + 45, // Position higher with more padding from bottom
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
              CupertinoIcons.person_2_fill,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No more beer buddies nearby',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pull to refresh',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              textAlign: TextAlign.center,
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
