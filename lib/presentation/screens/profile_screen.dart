import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:flutter_svg/flutter_svg.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/avatar_service.dart';

/// Production-ready profile screen following Apple HIG guidelines
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _likedUsers = 0;
  int _likedBars = 0;
  int _matches = 0;
  bool _isUpdatingAvatar = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadProfile();
  }

  // Load avatar url from users table and initialize if needed
  Future<void> _loadProfile() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    try {
      // Get current avatar URL
      String? url = await AvatarService.getCurrentUserAvatarUrl();

      // If user doesn't have an avatar, initialize one
      if (url == null || url.isEmpty) {
        setState(() => _isUpdatingAvatar = true);
        url = await AvatarService.initializeUserAvatar(userId);
        setState(() => _isUpdatingAvatar = false);
      }

      if (mounted) {
        setState(() {
          _avatarUrl = url;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdatingAvatar = false;
          _avatarUrl = null;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final likedUsers = prefs.getStringList('liked_users') ?? [];
    final likedBars = prefs.getStringList('liked_bars') ?? [];
    final matches = prefs.getStringList('matches') ?? [];

    setState(() {
      _likedUsers = likedUsers.length;
      _likedBars = likedBars.length;
      _matches = matches.length;
    });
  }

  void _signOut() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Sign Out'),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
    );
  }

  void _clearData() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Data'),
        content: const Text('This will clear all your liked bars, users, and matches. This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () async {
              Navigator.of(context).pop();
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('liked_users');
              await prefs.remove('disliked_users');
              await prefs.remove('liked_bars');
              await prefs.remove('disliked_bars');
              await prefs.remove('matches');
              await prefs.remove('last_checkin');
              await _loadStats();
            },
          ),
        ],
      ),
    );
  }

  void _changeAvatar() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Change Avatar'),
        content: const Text('Generate a new random avatar?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Generate'),
            onPressed: () {
              Navigator.of(context).pop();
              _generateNewRandomAvatar();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generateNewRandomAvatar() async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      _showErrorMessage('User not authenticated');
      return;
    }

    setState(() => _isUpdatingAvatar = true);
    try {
      final newAvatarUrl = await AvatarService.regenerateAvatar(userId);
      if (newAvatarUrl != null) {
        setState(() {
          _avatarUrl = newAvatarUrl;
        });
        if (mounted) _showSuccessMessage('Avatar updated successfully!');
      } else {
        if (mounted) _showErrorMessage('Failed to update avatar. Please try again.');
      }
    } catch (e) {
      if (mounted) _showErrorMessage('An error occurred while updating avatar');
    } finally {
      if (mounted) setState(() => _isUpdatingAvatar = false);
    }
  }

  void _showSuccessMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profile'),
        border: null,
      ),
      child: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            final user = state.user;
            final userName = user.userMetadata?['name'] as String? ?? 'User';
            final userAge = user.userMetadata?['age'] as int? ?? 0;

            // Display with Material ListView and CircleAvatar
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Avatar display using SVG support
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.systemGrey5,
                    ),
                    child: ClipOval(
                      child: _isUpdatingAvatar
                          ? const Center(child: CupertinoActivityIndicator())
                          : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                              ? SvgPicture.network(
                                  _avatarUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholderBuilder: (_) => const Center(child: CupertinoActivityIndicator()),
                                )
                              : const Icon(
                                  CupertinoIcons.person_fill,
                                  size: 50,
                                  color: CupertinoColors.systemGrey,
                                ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Button to regenerate avatar
                  CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: _isUpdatingAvatar ? null : _generateNewRandomAvatar,
                    child: const Text('Generate Avatar'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Stats Section
                  CupertinoFormSection.insetGrouped(
                    header: const Text('STATISTICS'),
                    children: [
                      _buildStatRow(
                        icon: CupertinoIcons.person_2_fill,
                        label: 'Liked Users',
                        value: _likedUsers,
                        color: CupertinoColors.systemPink,
                      ),
                      _buildStatRow(
                        icon: CupertinoIcons.location_fill,
                        label: 'Liked Bars',
                        value: _likedBars,
                        color: CupertinoColors.systemOrange,
                      ),
                      _buildStatRow(
                        icon: CupertinoIcons.heart_fill,
                        label: 'Matches',
                        value: _matches,
                        color: CupertinoColors.systemRed,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Actions Section
                  CupertinoFormSection.insetGrouped(
                    header: const Text('ACTIONS'),
                    children: [
                      CupertinoFormRow(
                        prefix: const Icon(
                          CupertinoIcons.refresh,
                          color: CupertinoColors.systemBlue,
                        ),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          onPressed: _loadStats,
                          child: const Text(
                            'Refresh Statistics',
                            style: TextStyle(
                              color: CupertinoColors.label,
                            ),
                          ),
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: const Icon(
                          CupertinoIcons.clear,
                          color: CupertinoColors.systemOrange,
                        ),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          onPressed: _clearData,
                          child: const Text(
                            'Clear Data',
                            style: TextStyle(
                              color: CupertinoColors.label,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Sign Out Button
                  CupertinoButton(
                    color: CupertinoColors.destructiveRed,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: _signOut,
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Version
                  const Text(
                    'Beer Tinder v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return CupertinoFormRow(
      prefix: Icon(
        icon,
        color: color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
