import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../theme/theme.dart';
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
        title: Text(
          'Sign Out',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Cancel',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.systemBlue(context),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(
              'Sign Out',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.systemRed(context),
              ),
            ),
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
        title: Text(
          'Clear Data',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'This will clear all your liked bars, users, and matches. This action cannot be undone.',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Cancel',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.systemBlue(context),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(
              'Clear',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.systemRed(context),
              ),
            ),
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
        title: Text(
          'Success',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          message,
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

  void _showErrorMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Error',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          message,
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Profile',
          style: AppTheme.navTitle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        backgroundColor: AppTheme.isDarkMode(context)
            ? AppTheme.darkCardColor
            : Colors.white,
        border: null,
      ),
      child: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) {
              return Center(
                child: CupertinoActivityIndicator(
                  color: AppTheme.isDarkMode(context)
                      ? AppTheme.primaryColor
                      : AppTheme.primaryDarkColor,
                ),
              );
            }

            final user = state.user;
            final userName = user.userMetadata?['name'] as String? ?? 'User';

            // Display with ListView
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Avatar display using SVG support
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.isDarkMode(context)
                            ? AppTheme.systemGray4(context)
                            : AppTheme.systemGray5(context),
                      ),
                      child: ClipOval(
                        child: _isUpdatingAvatar
                            ? Center(
                                child: CupertinoActivityIndicator(
                                  color: AppTheme.isDarkMode(context)
                                      ? AppTheme.primaryColor
                                      : AppTheme.primaryDarkColor,
                                ),
                              )
                            : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                ? SvgPicture.network(
                                    _avatarUrl!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholderBuilder: (_) => Center(
                                      child: CupertinoActivityIndicator(
                                        color: AppTheme.isDarkMode(context)
                                            ? AppTheme.primaryColor
                                            : AppTheme.primaryDarkColor,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    CupertinoIcons.person_fill,
                                    size: 50,
                                    color: AppTheme.iconColor(context),
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Button to regenerate avatar
                  Center(
                    child: CupertinoButton(
                      color: AppTheme.systemBlue(context),
                      borderRadius: BorderRadius.circular(8),
                      onPressed: _isUpdatingAvatar ? null : _generateNewRandomAvatar,
                      child: Text(
                        'Generate Avatar',
                        style: AppTheme.buttonStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: AppTheme.title3.copyWith(
                      color: AppTheme.textColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? '',
                    style: AppTheme.headline.copyWith(
                      color: AppTheme.secondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Stats Section
                  _buildSectionHeader('STATISTICS'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildStatRow(
                          icon: CupertinoIcons.person_2_fill,
                          label: 'Liked Users',
                          value: _likedUsers,
                          color: AppTheme.systemPink(context),
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppTheme.dividerColor(context),
                        ),
                        _buildStatRow(
                          icon: CupertinoIcons.location_fill,
                          label: 'Liked Bars',
                          value: _likedBars,
                          color: AppTheme.systemOrange(context),
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppTheme.dividerColor(context),
                        ),
                        _buildStatRow(
                          icon: CupertinoIcons.heart_fill,
                          label: 'Matches',
                          value: _matches,
                          color: AppTheme.systemRed(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions Section
                  _buildSectionHeader('ACTIONS'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildActionRow(
                          icon: CupertinoIcons.refresh,
                          label: 'Refresh Statistics',
                          color: AppTheme.systemBlue(context),
                          onTap: _loadStats,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppTheme.dividerColor(context),
                        ),
                        _buildActionRow(
                          icon: CupertinoIcons.clear,
                          label: 'Clear Data',
                          color: AppTheme.systemOrange(context),
                          onTap: _clearData,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sign Out Button
                  CupertinoButton(
                    color: AppTheme.systemRed(context),
                    borderRadius: BorderRadius.circular(8),
                    onPressed: _signOut,
                    child: Text(
                      'Sign Out',
                      style: AppTheme.buttonStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Version
                  Text(
                    'Beer Tinder v1.0.0',
                    style: AppTheme.caption2.copyWith(
                      color: AppTheme.secondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: AppTheme.footnote.copyWith(
          color: AppTheme.secondaryTextColor(context),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textColor(context),
              ),
            ),
          ),
          Text(
            '$value',
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textColor(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: AppTheme.iconColor(context),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Color systemPink(BuildContext context) {
    return AppTheme.isDarkMode(context)
        ? const Color(0xFFFF375F) // System Pink Dark
        : const Color(0xFFFF2D55); // System Pink Light
  }

  Color systemOrange(BuildContext context) {
    return AppTheme.isDarkMode(context)
        ? const Color(0xFFFF9F0A) // System Orange Dark
        : const Color(0xFFFF9500); // System Orange Light
  }
}
