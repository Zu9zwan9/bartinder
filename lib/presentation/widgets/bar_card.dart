import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../domain/entities/bar.dart';
import '../theme/theme.dart';

class BarCard extends StatelessWidget {
  final Bar bar;
  final VoidCallback onTap;

  const BarCard({super.key, required this.bar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final smallTextStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontSize: 12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                bar.photoUrl ??
                    'https://images.unsplash.com/photo-1546726747-421c6d69c929',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.primaryColor.withAlpha(51),
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
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GlassmorphicContainer(
                  width: double.infinity,
                  height: 180,
                  borderRadius: 0,
                  blur: 10,
                  alignment: Alignment.bottomCenter,
                  border: 0,
                  linearGradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withAlpha(26),
                      Colors.white.withAlpha(76),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withAlpha(26),
                      Colors.white.withAlpha(26),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                bar.name,
                                style: AppTheme.titleStyle.copyWith(
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black.withAlpha(128),
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(153), // Using withAlpha instead of withOpacity
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
                                    style: smallTextStyle?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                                color: AppTheme.primaryColor.withAlpha(204),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                type,
                                style: smallTextStyle?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (bar.crowdLevel != null) ...[
                              _buildInfoChip(
                                context,
                                icon: CupertinoIcons.person_3_fill,
                                label: 'Crowd: ${bar.crowdLevel}',
                                color: _getCrowdLevelColor(bar.crowdLevel!),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (bar.hasDiscount)
                              _buildInfoChip(
                                context,
                                icon: CupertinoIcons.tag_fill,
                                label: bar.discountPercentage != null
                                    ? '${bar.discountPercentage}% Off'
                                    : 'Discount',
                                color: AppTheme.successColor(context),
                              ),
                          ],
                        ),
                        if (bar.plannedVisitorsCount != null &&
                            bar.plannedVisitorsCount! > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.person_2_fill,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${bar.plannedVisitorsCount} ${bar.plannedVisitorsCount == 1 ? 'person' : 'people'} planning to visit',
                                style: smallTextStyle?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (bar.events != null && bar.events!.isNotEmpty)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.calendar,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Events: ${bar.events!.length}',
                          style: smallTextStyle?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final smallTextStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontSize: 12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(204),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(label, style: smallTextStyle?.copyWith(color: Colors.white)),
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
}
