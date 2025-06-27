import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Widget for filtering bars by distance
class DistanceFilterWidget extends StatefulWidget {
  final double currentDistance;
  final Function(double) onDistanceChanged;
  final bool isVisible;

  const DistanceFilterWidget({
    super.key,
    required this.currentDistance,
    required this.onDistanceChanged,
    this.isVisible = true,
  });

  @override
  State<DistanceFilterWidget> createState() => _DistanceFilterWidgetState();
}

class _DistanceFilterWidgetState extends State<DistanceFilterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  double _tempDistance = 25.0;

  @override
  void initState() {
    super.initState();
    _tempDistance = widget.currentDistance;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(DistanceFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    if (widget.currentDistance != oldWidget.currentDistance) {
      setState(() {
        _tempDistance = widget.currentDistance;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.isDarkMode(context)
                    ? AppTheme.darkCardColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Distance Filter',
                        style: AppTheme.titleStyle.copyWith(
                          color: AppTheme.textColor(context),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${_tempDistance.toStringAsFixed(0)} km',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CupertinoSlider(
                    value: _tempDistance,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    activeColor: AppTheme.primaryColor,
                    thumbColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _tempDistance = value;
                      });
                    },
                    onChangeEnd: (value) {
                      widget.onDistanceChanged(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1 km',
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.textColor(context).withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '50 km',
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.textColor(context).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.location,
                        size: 16,
                        color: AppTheme.textColor(context).withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Show bars within ${_tempDistance.toStringAsFixed(0)} km of your location',
                          style: AppTheme.captionStyle.copyWith(
                            color: AppTheme.textColor(context).withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
