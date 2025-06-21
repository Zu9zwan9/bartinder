import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user.dart' as app_user;
import '../theme/theme.dart';

/// Widget for displaying a horizontal list of users heading to a bar
class HeadingUsersList extends StatefulWidget {
  final List<String> userIds;

  const HeadingUsersList({
    super.key,
    required this.userIds,
  });

  @override
  State<HeadingUsersList> createState() => _HeadingUsersListState();
}

class _HeadingUsersListState extends State<HeadingUsersList> {
  final UserRepositoryImpl _userRepository = UserRepositoryImpl();
  List<app_user.User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all users
      final allUsers = await _userRepository.getUsers();

      // Filter users by IDs
      _users = allUsers.where((user) => widget.userIds.contains(user.id)).toList();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    if (_users.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserItem(user);
        },
      ),
    );
  }

  Widget _buildUserItem(app_user.User user) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // User avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // TODO: заменить на withAlpha при обновлении Flutter
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                user.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.primaryColor.withOpacity(0.2), // TODO: заменить на withAlpha при обновлении Flutter
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          // User name
          Text(
            user.name,
            style: AppTheme.bodyStyle.copyWith(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
