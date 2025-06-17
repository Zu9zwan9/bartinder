import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../domain/entities/user.dart';
import '../theme/theme.dart';

/// Dialog shown when a match is created
class MatchDialog extends StatelessWidget {
  final User matchedUser;
  final VoidCallback onContinue;
  final VoidCallback? onMessage;

  const MatchDialog({
    super.key,
    required this.matchedUser,
    required this.onContinue,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 400,
        borderRadius: 20,
        blur: AppTheme.glassmorphismBlur,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.2),
            AppTheme.primaryColor.withOpacity(0.4),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.6),
            AppTheme.primaryColor.withOpacity(0.6),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            // Match title
            Text(
              'It\'s a Match! 🍻',
              style: AppTheme.headlineStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // User photo
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(matchedUser.photoUrl),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
              child: ClipOval(
                child: Image.network(
                  matchedUser.photoUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User name and info
            Text(
              matchedUser.name,
              style: AppTheme.titleStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loves ${matchedUser.favoriteBeer}',
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.white,
              ),
            ),

            if (matchedUser.lastCheckedInLocation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Last seen at ${matchedUser.lastCheckedInLocation}',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Message button
                if (onMessage != null)
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    color: AppTheme.primaryColor,
                    onPressed: onMessage,
                    child: const Text(
                      'Message',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(width: 16),

                // Continue button
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  color: Colors.white,
                  onPressed: onContinue,
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
