// TODO Implement this library.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../core/services/location_service.dart';
import '../../data/repositories/location_repository.dart';

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
  final _locationRepo = LocationRepository();
  final String _userId = 'user_test1'; // Замените на реальный userId при необходимости
  final _userRepoImpl = UserRepositoryImpl();

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
              onPressed: _loadStats,
              child: const Text('Refresh Stats'),
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
            const SizedBox(height: 16),
            // Show location button
            CupertinoButton.filled(
              child: const Text('Показать локацию'),
              onPressed: () async {
                final service = LocationService();
                final position = await service.getCurrentLocation();
                if (!mounted) return;
                showCupertinoDialog(
                  context: context,
                  builder: (ctx) => CupertinoAlertDialog(
                    title: const Text('Ваша локация'),
                    content: Text(
                      position == null
                          ? 'Не удалось получить локацию'
                          : 'Широта: \\${position.latitude}\nДолгота: \\${position.longitude}',
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Save location to Firebase button
            CupertinoButton.filled(
              child: const Text('Сохранить локацию в Firebase'),
              onPressed: () async {
                final service = LocationService();
                final position = await service.getCurrentLocation();
                if (position == null) {
                  if (!mounted) return;
                  showCupertinoDialog(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('Ошибка'),
                      content: const Text('Не удалось получить локацию'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                await _locationRepo.saveUserLocation(
                  userId: _userId,
                  latitude: position.latitude,
                  longitude: position.longitude,
                );
                if (!mounted) return;
                showCupertinoDialog(
                  context: context,
                  builder: (ctx) => CupertinoAlertDialog(
                    title: const Text('Успех'),
                    content: const Text('Локация сохранена в Firebase!'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Show location from Supabase button
            CupertinoButton.filled(
              child: const Text('Показать локацию из Supabase'),
              onPressed: () async {
                final response = await _locationRepo.supabase
                    .from('users')
                    .select()
                    .eq('id', _userId)
                    .single();
                if (!mounted) return;
                showCupertinoDialog(
                  context: context,
                  builder: (ctx) => CupertinoAlertDialog(
                    title: const Text('Локация из Supabase'),
                    content: Text(
                      (response == null || response['latitude'] == null || response['longitude'] == null)
                          ? 'Нет данных'
                          : 'Широта: \\${response['latitude']}\nДолгота: \\${response['longitude']}',
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Create test users in DB button
            CupertinoButton.filled(
              child: const Text('Create test users in DB'),
              onPressed: () async {
                await _userRepoImpl.createTestUsers();
                if (!mounted) return;
                showCupertinoDialog(
                  context: context,
                  builder: (ctx) => CupertinoAlertDialog(
                    title: const Text('Success'),
                    content: const Text('Test users created in Supabase!'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Get all users from DB button
            CupertinoButton.filled(
              child: const Text('Get all users from DB'),
              onPressed: () async {
                final users = await _userRepoImpl.getAllUsersRaw();
                if (!mounted) return;
                showCupertinoDialog(
                  context: context,
                  builder: (ctx) => CupertinoAlertDialog(
                    title: const Text('Users from Supabase'),
                    content: Text(users.isEmpty
                        ? 'No users found.'
                        : users.map((u) => u.name).join('\n')),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Create test data button
            CupertinoButton(
              color: CupertinoColors.systemGreen,
              child: const Text('Создать тестовые данные'),
              onPressed: () async {
                // Пример тестовых данных
                final testUser = {
                  'id': 'test_user_1',
                  'name': 'Test User',
                  'age': 25,
                  'photoUrl': 'https://randomuser.me/api/portraits/lego/2.jpg',
                  'favoriteBeer': 'IPA',
                  'bio': 'Это тестовый пользователь',
                  'beerPreferences': ['IPA', 'Stout'],
                  'lastCheckedInLocation': 'Test Bar',
                  'lastCheckedInDistance': 1.2,
                };
                try {
                  final supabase = Supabase.instance.client;
                  await supabase.from('users').upsert([testUser]);
                  if (!mounted) return;
                  showCupertinoDialog(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('Успех'),
                      content: const Text('Тестовые данные созданы!'),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  showCupertinoDialog(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('Ошибка'),
                      content: Text('Не удалось создать тестовые данные: \n${e.toString()}'),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  );
                }
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
