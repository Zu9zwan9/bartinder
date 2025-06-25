import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/match_preferences.dart';
import '../../domain/entities/distance_filter.dart';
import '../theme/theme.dart';

class DistanceFilterWidget extends StatefulWidget {
  final MatchPreferences? currentPreferences;
  final Function(int distance) onDistanceChanged;
  final Function(List<int> ageRange) onAgeRangeChanged;
  final Function(List<String> genderPreference) onGenderPreferenceChanged;
  final Function(DistanceFilter distanceFilter)? onDistanceFilterChanged;
  final DistanceFilter? initialDistanceFilter;

  const DistanceFilterWidget({
    super.key,
    this.currentPreferences,
    required this.onDistanceChanged,
    required this.onAgeRangeChanged,
    required this.onGenderPreferenceChanged,
    this.onDistanceFilterChanged,
    this.initialDistanceFilter,
  });

  @override
  State<DistanceFilterWidget> createState() => _DistanceFilterWidgetState();
}

class _DistanceFilterWidgetState extends State<DistanceFilterWidget> {
  late int _currentDistance;
  late RangeValues _ageRange;
  late Set<String> _selectedGenders;
  DistanceFilter? _selectedDistanceFilter;
  late bool _useSpecificDistanceFilter;

  final List<String> _availableGenders = [
    'Male',
    'Female',
    'Non-binary',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _currentDistance = widget.currentPreferences?.maxDistanceKm ?? 25;
    _ageRange = RangeValues(
      widget.currentPreferences?.ageRange[0].toDouble() ?? 18.0,
      widget.currentPreferences?.ageRange[1].toDouble() ?? 65.0,
    );
    _selectedGenders =
        widget.currentPreferences?.genderPreference.toSet() ?? {};
    _selectedDistanceFilter = widget.initialDistanceFilter;
    _useSpecificDistanceFilter = widget.initialDistanceFilter != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.grey,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Distance Filter Mode Toggle
          _buildDistanceFilterModeToggle(),
          const SizedBox(height: 16),

          // Distance Filter
          _useSpecificDistanceFilter
              ? _buildSpecificDistanceFilter()
              : _buildDistanceFilter(),
          const SizedBox(height: 32),

          // Age Range Filter
          _buildAgeRangeFilter(),
          const SizedBox(height: 32),

          // Gender Preference Filter
          _buildGenderPreferenceFilter(),
          const SizedBox(height: 32),

          // Apply Button
          _buildApplyButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maximum Distance',
              style: AppTheme.titleStyle.copyWith(fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$_currentDistance km',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.primaryColor.withAlpha(77),
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withAlpha(51),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _currentDistance.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            onChanged: (value) {
              setState(() {
                _currentDistance = value.round();
              });
            },
            onChangeEnd: (value) {
              widget.onDistanceChanged(_currentDistance);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 km', style: AppTheme.captionStyle),
            Text('100 km', style: AppTheme.captionStyle),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Age Range',
              style: AppTheme.titleStyle.copyWith(fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(
                  26,
                ), // Replaced withOpacity(0.1) with withAlpha(26)
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_ageRange.start.round()}-${_ageRange.end.round()}',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.primaryColor.withAlpha(77),
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withAlpha(51),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: RangeSlider(
            values: _ageRange,
            min: 18,
            max: 80,
            divisions: 62,
            onChanged: (values) {
              setState(() {
                _ageRange = values;
              });
            },
            onChangeEnd: (values) {
              widget.onAgeRangeChanged([
                values.start.round(),
                values.end.round(),
              ]);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('18', style: AppTheme.captionStyle),
            Text('80', style: AppTheme.captionStyle),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderPreferenceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Show Me', style: AppTheme.titleStyle.copyWith(fontSize: 18)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: _availableGenders.map((gender) {
            final isSelected = _selectedGenders.contains(gender);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedGenders.remove(gender);
                  } else {
                    _selectedGenders.add(gender);
                  }
                });
                widget.onGenderPreferenceChanged(_selectedGenders.toList());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  gender,
                  style: AppTheme.bodyStyle.copyWith(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistanceFilterModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useSpecificDistanceFilter = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_useSpecificDistanceFilter
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_useSpecificDistanceFilter
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(
                              26,
                            ), // Replaced withOpacity(0.1) with withAlpha(26)
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Distance Range',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: !_useSpecificDistanceFilter
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: !_useSpecificDistanceFilter
                        ? AppTheme.primaryColor
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useSpecificDistanceFilter = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _useSpecificDistanceFilter
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _useSpecificDistanceFilter
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(
                              26,
                            ), // Replaced withOpacity(0.1) with withAlpha(26)
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Quick Filters',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: _useSpecificDistanceFilter
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: _useSpecificDistanceFilter
                        ? AppTheme.primaryColor
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Find Users', style: AppTheme.titleStyle.copyWith(fontSize: 18)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: DistanceFilter.values.map((filter) {
            final isSelected = _selectedDistanceFilter == filter;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDistanceFilter = filter;
                });
                if (widget.onDistanceFilterChanged != null) {
                  widget.onDistanceFilterChanged!(filter);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(
                        13,
                      ), // Replaced withOpacity(0.05) with withAlpha(13)
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForFilter(filter),
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filter.displayName,
                      style: AppTheme.bodyStyle.copyWith(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedDistanceFilter != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(
                26,
              ), // Replaced withOpacity(0.1) with withAlpha(26)
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedDistanceFilter!.description,
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  IconData _getIconForFilter(DistanceFilter filter) {
    switch (filter) {
      case DistanceFilter.nearby100m:
      case DistanceFilter.nearby250m:
      case DistanceFilter.nearby500m:
        return Icons.my_location;
      case DistanceFilter.inMyCity:
        return Icons.location_city;
      case DistanceFilter.inNearbyCity:
        return Icons.map;
      case DistanceFilter.inOtherCountry:
        return Icons.public;
    }
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        onPressed: () {
          if (_useSpecificDistanceFilter && _selectedDistanceFilter != null) {
            widget.onDistanceFilterChanged?.call(_selectedDistanceFilter!);
          }
          Navigator.of(context).pop();
        },
        child: Text(
          'Apply Filters',
          style: AppTheme.bodyStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
