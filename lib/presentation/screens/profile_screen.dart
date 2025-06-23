import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../../data/services/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadStats();
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
    setState(() {
      _isUpdatingAvatar = true;
    });

    try {
      final result = await AuthService.updateAvatar(AuthService.generateRandomAvatar());
      if (result.isSuccess) {
        context.read<AuthBloc>().add(const AuthStatusRequested());
        if (mounted) {
          _showSuccessMessage('Avatar updated successfully!');
        }
      } else {
        if (mounted) {
          _showErrorMessage(result.error?.message ?? 'Failed to update avatar');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('An error occurred while updating avatar');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAvatar = false;
        });
      }
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
            final avatarUrl = user.userMetadata?['avatar_url'] as String?;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Avatar
                  GestureDetector(
                    onTap: _isUpdatingAvatar ? null : _changeAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.systemGrey5.resolveFrom(context),
                            border: Border.all(
                              color: _isUpdatingAvatar
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.systemGrey4.resolveFrom(context),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: _isUpdatingAvatar
                                ? const Center(
                                    child: CupertinoActivityIndicator(),
                                  )
                                : avatarUrl != null
                                    ? Image.network(
                                        avatarUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            CupertinoIcons.person_fill,
                                            size: 60,
                                            color: CupertinoColors.systemGrey,
                                          );
                                        },
                                      )
                                    : const Icon(
                                        CupertinoIcons.person_fill,
                                        size: 60,
                                        color: CupertinoColors.systemGrey,
                                      ),
                          ),
                        ),
                        if (!_isUpdatingAvatar)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.activeBlue,
                                border: Border.all(
                                  color: CupertinoColors.systemBackground.resolveFrom(context),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                CupertinoIcons.camera_fill,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Avatar change hint
                  if (!_isUpdatingAvatar)
                    Text(
                      'Tap to change avatar',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // User Age
                  if (userAge > 0)
                    Text(
                      '$userAge years old',
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // User Email
                  Text(
                    user.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
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
