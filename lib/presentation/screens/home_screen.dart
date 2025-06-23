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
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Beer Tinder'),
        ),
        child: SafeArea(
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
                return state.users.isEmpty
                    ? _buildEmptyState()
                    : _buildSwipeCards(context, state.users);
              } else if (state is UserSwipeError) {
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

  Widget _buildSwipeCards(BuildContext context, List<User> users) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CardSwiper(
              controller: _cardController,
              cardsCount: users.length,
              onSwipe: (prev, curr, dir) {
                final user = users[prev];
                _userSwipeBloc.add(
                  dir == CardSwiperDirection.right ? LikeUser(user) : DislikeUser(user),
                );
                return true;
              },
              numberOfCardsDisplayed: math.min(3, users.length),
              backCardOffset: const Offset(20, 20),
              padding: const EdgeInsets.all(24),
              cardBuilder: (BuildContext context, int index, int horizontalOffset, int verticalOffset) {
                return UserCard(user: users[index]);
              },
            ),
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
              color: Colors.black.withOpacity(0.1),
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
            CupertinoIcons.person_2_fill,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text('No more beer buddies nearby', style: AppTheme.titleStyle),
          const SizedBox(height: 8),
          Text(
            'Check back later or expand your search radius',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppTheme.primaryColor,
            onPressed: () => _userSwipeBloc.add(const LoadUsers()),
            child: const Text('Refresh'),
          ),
        ],
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
