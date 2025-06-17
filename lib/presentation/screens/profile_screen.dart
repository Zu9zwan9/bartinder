// TODO Implement this library.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';

/// Profile screen showing user statistics
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _likedUsers = 0;
  int _likedBars = 0;
  int _matches = 0;
  late final UserRepository _userRepo;

  @override
  void initState() {
    super.initState();
    _userRepo = UserRepositoryImpl();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final likedUsers = prefs.getStringList('liked_users') ?? [];
    final likedBars = prefs.getStringList('liked_bars') ?? [];
    final matchIds = await _userRepo.getMatches();
    setState(() {
      _likedUsers = likedUsers.length;
      _likedBars = likedBars.length;
      _matches = matchIds.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profile'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/lego/1.jpg',
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Your Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            _buildStatTile(
              icon: CupertinoIcons.person_2_fill,
              label: 'Liked Users',
              value: _likedUsers,
            ),
            _buildStatTile(
              icon: CupertinoIcons.map_fill,
              label: 'Liked Bars',
              value: _likedBars,
            ),
            _buildStatTile(
              icon: CupertinoIcons.heart_fill,
              label: 'Matches',
              value: _matches,
            ),
            const SizedBox(height: 32),
            // Refresh stats button
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              child: const Text('Refresh Stats'),
              onPressed: _loadStats,
            ),
            const SizedBox(height: 16),
            // Clear stored data
            CupertinoButton(
              color: CupertinoColors.destructiveRed,
              child: const Text('Clear Data'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('liked_users');
                await prefs.remove('disliked_users');
                await prefs.remove('liked_bars');
                await prefs.remove('disliked_bars');
                await prefs.remove('last_checkin');
                setState(() {
                  _likedUsers = 0;
                  _likedBars = 0;
                  _matches = 0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: CupertinoColors.activeBlue),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
