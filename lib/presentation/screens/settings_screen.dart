import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/auth_service.dart';
import '../../data/repositories/match_preferences_repository.dart';
import '../blocs/match_preferences/match_preferences_bloc.dart';
import '../blocs/theme/theme_bloc.dart';
import '../theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late MatchPreferencesBloc _matchPreferencesBloc;
  final supabase = Supabase.instance.client;
  late String userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser?.id ?? '';
    _matchPreferencesBloc = MatchPreferencesBloc(
      repository: MatchPreferencesRepository(),
      userId: userId,
    );
    _matchPreferencesBloc.add(LoadMatchPreferences());
  }

  @override
  void dispose() {
    _matchPreferencesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _matchPreferencesBloc,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        appBar: AppBar(
          backgroundColor: AppTheme.cardColor(context),
          elevation: 0,
          title: Text(
            'Settings',
            style: AppTheme.titleStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor(context),
            ),
          ),
          iconTheme: IconThemeData(
            color: AppTheme.textColor(context),
          ),
        ),
        body: _isLoading
            ? Center(child: CupertinoActivityIndicator(
                color: AppTheme.primaryColor,
              ))
            : _buildSettingsList(),
      ),
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildProfileSection(),
        const SizedBox(height: 16),
        _buildThemeSection(),
        const SizedBox(height: 16),
        _buildPreferencesSection(),
        const SizedBox(height: 16),
        _buildPrivacySection(),
        const SizedBox(height: 16),
        _buildAccountSection(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: AppTheme.subtitleStyle.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Profile'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: CupertinoIcons.person_fill,
                title: 'Edit Profile',
                onTap: () => _navigateToEditProfile(),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: CupertinoIcons.photo,
                title: 'Profile Photos',
                onTap: () => _navigateToProfilePhotos(),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: CupertinoIcons.bubble_left_bubble_right_fill,
                title: 'Bio',
                onTap: () => _navigateToEditBio(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Theme'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: CupertinoIcons.sun_max_fill,
                title: 'Light Theme',
                onTap: () => _setLightTheme(),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: CupertinoIcons.moon_stars_fill,
                title: 'Dark Theme',
                onTap: () => _setDarkTheme(),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: CupertinoIcons.paintbrush_fill,
                title: 'Customize Theme',
                onTap: () => _navigateToCustomizeTheme(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Preferences'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: BlocBuilder<MatchPreferencesBloc, MatchPreferencesState>(
            builder: (context, state) {
              String distanceValue = '10 km';
              String ageRangeValue = '18-65';

              if (state is MatchPreferencesLoaded) {
                final prefs = state.preferences;
                distanceValue = '${prefs.maxDistanceKm} km';
                ageRangeValue = '${prefs.ageRange[0]}-${prefs.ageRange[1]}';
              }

              return Column(
                children: [
                  _buildSettingsItem(
                    icon: CupertinoIcons.location_circle_fill,
                    title: 'Distance',
                    subtitle: distanceValue,
                    onTap: () => _navigateToDistanceSettings(),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    icon: CupertinoIcons.person_2_fill,
                    title: 'Age Range',
                    subtitle: ageRangeValue,
                    onTap: () => _navigateToAgeRangeSettings(),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    icon: CupertinoIcons.heart_fill,
                    title: 'Beer Preferences',
                    onTap: () => _navigateToBeerPreferences(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Privacy'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: CupertinoIcons.bell_fill,
                title: 'Notifications',
                onTap: () => _navigateToNotificationSettings(),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: CupertinoIcons.location_fill,
                title: 'Location Services',
                onTap: () => _navigateToLocationSettings(),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: CupertinoIcons.eye_slash_fill,
                title: 'Privacy Settings',
                onTap: () => _navigateToPrivacySettings(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Account'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: CupertinoIcons.lock_fill,
                title: 'Change Password',
                onTap: () => _navigateToChangePassword(),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: CupertinoIcons.info_circle_fill,
                title: 'About',
                onTap: () => _showAboutDialog(),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: CupertinoIcons.square_arrow_right_fill,
                title: 'Sign Out',
                textColor: Colors.red,
                onTap: () => _signOut(),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: CupertinoIcons.trash_fill,
                title: 'Delete Account',
                textColor: Colors.red,
                onTap: () => _showDeleteAccountConfirmation(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            'App Version 1.0.0',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(26), // Using withAlpha instead of withOpacity
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: textColor ?? AppTheme.textColor(context),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: AppTheme.iconColor(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 0,
      color: AppTheme.dividerColor(context),
    );
  }

  void _navigateToEditProfile() {
    // TODO: Implement navigation to edit profile screen
  }

  void _navigateToProfilePhotos() {
    // TODO: Implement navigation to profile photos screen
  }

  void _navigateToEditBio() {
    // TODO: Implement navigation to edit bio screen
  }

  void _navigateToDistanceSettings() {
    // TODO: Implement navigation to distance settings screen
  }

  void _navigateToAgeRangeSettings() {
    // TODO: Implement navigation to age range settings screen
  }

  void _navigateToBeerPreferences() {
    // TODO: Implement navigation to beer preferences screen
  }

  void _navigateToNotificationSettings() {
    // TODO: Implement navigation to notification settings screen
  }

  void _navigateToLocationSettings() {
    // TODO: Implement navigation to location settings screen
  }

  void _navigateToPrivacySettings() {
    // TODO: Implement navigation to privacy settings screen
  }

  void _navigateToChangePassword() {
    // TODO: Implement navigation to change password screen
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Beer Buddies'),
        content: const Text(
          'Beer Buddies helps you find people with similar beer preferences nearby. '
          'Connect with fellow beer enthusiasts and discover new brews together!\n\n'
          'Version 1.0.0\n'
          '© 2023 Beer Buddies Inc.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signOut();
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted. '
          'Are you sure you want to delete your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.admin.deleteUser(userId);
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setLightTheme() {
    context.read<ThemeBloc>().add(const ChangeThemeEvent(ThemeMode.light));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Light theme applied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _setDarkTheme() {
    context.read<ThemeBloc>().add(const ChangeThemeEvent(ThemeMode.dark));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dark theme applied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToCustomizeTheme() {
    // For future implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme customization coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
