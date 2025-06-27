import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/distance_filter.dart';
import '../theme/theme.dart';

/// Bottom sheet widget for selecting distance filters
class DistanceFilterSheet extends StatelessWidget {
  final DistanceFilter currentFilter;
  final Function(DistanceFilter) onFilterSelected;

  const DistanceFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Show me people',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Filter options
            ...DistanceFilter.values.map((filter) => _buildFilterOption(
              context,
              filter,
              filter == currentFilter,
            )),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    DistanceFilter filter,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          onFilterSelected(filter);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getIconForFilter(filter),
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filter.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      filter.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForFilter(DistanceFilter filter) {
    switch (filter) {
      case DistanceFilter.nearby100m:
      case DistanceFilter.nearby250m:
      case DistanceFilter.nearby500m:
        return CupertinoIcons.location_circle;
      case DistanceFilter.inMyCity:
        return CupertinoIcons.building_2_fill;
      case DistanceFilter.inNearbyCity:
        return CupertinoIcons.map;
      case DistanceFilter.inOtherCountry:
        return CupertinoIcons.globe;
    }
  }

  /// Static method to show the distance filter sheet
  static Future<DistanceFilter?> show(
    BuildContext context,
    DistanceFilter currentFilter,
  ) {
    return showModalBottomSheet<DistanceFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DistanceFilterSheet(
        currentFilter: currentFilter,
        onFilterSelected: (filter) => Navigator.of(context).pop(filter),
      ),
    );
  }
}
