import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:glassmorphism/glassmorphism.dart';
  import 'package:url_launcher/url_launcher.dart';

  import '../../domain/entities/bar.dart';
  import '../theme/theme.dart';
  import 'heading_users_list.dart';

  /// Screen for displaying bar details
  class BarDetailScreen extends StatelessWidget {
    final Bar bar;
    final VoidCallback onCheckIn;

    const BarDetailScreen({
      super.key,
      required this.bar,
      required this.onCheckIn,
    });

    @override
    Widget build(BuildContext context) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(bar.name),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.location_fill),
            onPressed: () => _openMaps(bar.latitude, bar.longitude, bar.name),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Bar image
                      Image.network(
                        bar.photoUrl ?? 'https://images.unsplash.com/photo-1546726747-421c6d69c929',
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.photo,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),

                      // Glassmorphic info panel
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: 80,
                          borderRadius: 0,
                          blur: 10,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bar.name,
                                      style: AppTheme.titleStyle.copyWith(
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 4,
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bar.address,
                                      style: AppTheme.bodyStyle.copyWith(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.location_solid,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${bar.distance.toStringAsFixed(1)} km',
                                        style: AppTheme.bodyStyle.copyWith(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bar info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (bar.description != null) ...[
                        Text(
                          'About',
                          style: AppTheme.subtitleStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bar.description!,
                          style: AppTheme.bodyStyle,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Beer types
                      Text(
                        'Beer Types',
                        style: AppTheme.subtitleStyle,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: bar.beerTypes.map((type) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type,
                              style: AppTheme.bodyStyle.copyWith(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Crowd level and discount
                      Row(
                        children: [
                          if (bar.crowdLevel != null) ...[
                            _buildInfoChip(
                              icon: CupertinoIcons.person_3_fill,
                              label: 'Crowd: ${bar.crowdLevel}',
                              color: _getCrowdLevelColor(bar.crowdLevel!),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (bar.hasDiscount)
                            _buildInfoChip(
                              icon: CupertinoIcons.tag_fill,
                              label: bar.discountPercentage != null
                                  ? '${bar.discountPercentage}% Off'
                                  : 'Discount',
                              color: AppTheme.successColor,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Events
                      if (bar.events != null && bar.events!.isNotEmpty) ...[
                        Text(
                          'Upcoming Events',
                          style: AppTheme.subtitleStyle,
                        ),
                        const SizedBox(height: 8),
                        ...bar.events!.map((event) => _buildEventCard(event)),
                        const SizedBox(height: 16),
                      ],

                      // Users heading there
                      if (bar.usersHeadingThere.isNotEmpty) ...[
                        Text(
                          'People Heading There',
                          style: AppTheme.subtitleStyle,
                        ),
                        const SizedBox(height: 8),
                        HeadingUsersList(userIds: bar.usersHeadingThere),
                        const SizedBox(height: 16),
                      ],

                      // Check-in button
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: AppTheme.primaryColor,
                          onPressed: onCheckIn,
                          child: const Text('Check In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildInfoChip({
      required IconData icon,
      required String label,
      required Color color,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildEventCard(Event event) {
      final now = DateTime.now();
      final isToday = event.startTime.day == now.day &&
          event.startTime.month == now.month &&
          event.startTime.year == now.year;
      final isTomorrow = event.startTime.day == now.day + 1 &&
          event.startTime.month == now.month &&
          event.startTime.year == now.year;

      String dateText;
      if (isToday) {
        dateText = 'Today';
      } else if (isTomorrow) {
        dateText = 'Tomorrow';
      } else {
        dateText = '${event.startTime.day}/${event.startTime.month}/${event.startTime.year}';
      }

      final timeText = '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}';

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.name,
                  style: AppTheme.subtitleStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$dateText at $timeText',
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 12,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: AppTheme.bodyStyle,
            ),
          ],
        ),
      );
    }

    Color _getCrowdLevelColor(String level) {
      switch (level.toLowerCase()) {
        case 'low':
          return Colors.green;
        case 'medium':
          return Colors.orange;
        case 'high':
          return Colors.red;
        default:
          return Colors.blue;
      }
    }

    Future<void> _openMaps(double latitude, double longitude, String name) async {
      final url = Uri.parse(
        'https://maps.apple.com/?q=$name&ll=$latitude,$longitude',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Fallback to Google Maps
        final googleUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        );
        if (await canLaunchUrl(googleUrl)) {
          await launchUrl(googleUrl);
        }
      }
    }
  }
