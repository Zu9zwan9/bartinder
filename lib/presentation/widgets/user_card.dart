import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../domain/entities/user.dart';
import '../theme/theme.dart';

/// A card widget that displays user information for swiping
class UserCard extends StatelessWidget {
  final User user;

  const UserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // User photo background
            Image.network(
              user.photoUrl,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              },
            ),

            // Glassmorphic info panel at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 160,
                borderRadius: 0,
                blur: AppTheme.glassmorphismBlur,
                alignment: Alignment.bottomCenter,
                border: 0,
                linearGradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and age
                      Row(
                        children: [
                          Text(
                            '${user.name}, ${user.age}',
                            style: AppTheme.titleStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Favorite beer
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.heart_fill,
                            color: AppTheme.accentColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.favoriteBeer,
                            style: AppTheme.bodyStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Last checked in location
                      if (user.lastCheckedInLocation != null)
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.location_fill,
                              color: AppTheme.successColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.lastCheckedInLocation} (${user.lastCheckedInDistance} km)',
                              style: AppTheme.bodyStyle.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),

                      // Bio
                      if (user.bio != null)
                        Text(
                          user.bio!,
                          style: AppTheme.captionStyle.copyWith(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Beer preferences chips
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.beerPreferences.map((preference) {
                  return GlassmorphicContainer(
                    width: preference.length * 10.0 + 16,
                    height: 32,
                    borderRadius: 16,
                    blur: AppTheme.glassmorphismBlur,
                    alignment: Alignment.center,
                    border: 0,
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
                        AppTheme.primaryColor.withOpacity(0.2),
                        AppTheme.primaryColor.withOpacity(0.2),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        preference,
                        style: AppTheme.captionStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
