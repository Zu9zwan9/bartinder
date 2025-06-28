import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/enhanced_location_service.dart';
import '../../domain/entities/user_location.dart';
import '../../core/services/user_location_service.dart';

/// Widget for managing location privacy settings
/// Follows Apple HIG guidelines for privacy controls
class LocationPrivacyWidget extends StatefulWidget {
  final LocationPrivacyLevel currentPrivacyLevel;
  final Function(LocationPrivacyLevel)? onPrivacyLevelChanged;
  final bool showExplanation;

  const LocationPrivacyWidget({
    super.key,
    this.currentPrivacyLevel = LocationPrivacyLevel.city,
    this.onPrivacyLevelChanged,
    this.showExplanation = true,
  });

  @override
  State<LocationPrivacyWidget> createState() => _LocationPrivacyWidgetState();
}

class _LocationPrivacyWidgetState extends State<LocationPrivacyWidget> {
  late LocationPrivacyLevel _selectedLevel;
  final UserLocationService _locationService = UserLocationService();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.currentPrivacyLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location Privacy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (widget.showExplanation) ...[
              const SizedBox(height: 8),
              Text(
                'Control how much of your location information is shared with other users.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...LocationPrivacyLevel.values.map((level) => _buildPrivacyOption(level)),
            if (_isUpdating) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(LocationPrivacyLevel level) {
    final isSelected = _selectedLevel == level;
    final info = _getPrivacyLevelInfo(level);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Icon(
          info.icon,
          color: isSelected ? Colors.blue : Colors.grey[600],
        ),
        title: Text(
          info.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : null,
          ),
        ),
        subtitle: Text(
          info.description,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Radio<LocationPrivacyLevel>(
          value: level,
          groupValue: _selectedLevel,
          onChanged: _onPrivacyLevelChanged,
          activeColor: Colors.blue,
        ),
        onTap: () => _onPrivacyLevelChanged(level),
      ),
    );
  }

  void _onPrivacyLevelChanged(LocationPrivacyLevel? level) async {
    if (level == null || level == _selectedLevel || _isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final result = await _locationService.updateLocationPrivacy(level);

      if (result.isSuccess) {
        setState(() {
          _selectedLevel = level;
        });

        widget.onPrivacyLevelChanged?.call(level);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Privacy settings updated to ${_getPrivacyLevelInfo(level).title}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update privacy settings: ${result.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating privacy settings: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  PrivacyLevelInfo _getPrivacyLevelInfo(LocationPrivacyLevel level) {
    switch (level) {
      case LocationPrivacyLevel.exact:
        return PrivacyLevelInfo(
          title: 'Exact Location',
          description: 'Share your precise address including street number',
          icon: Icons.my_location,
        );
      case LocationPrivacyLevel.street:
        return PrivacyLevelInfo(
          title: 'Street Level',
          description: 'Share your street without the specific number',
          icon: Icons.location_on,
        );
      case LocationPrivacyLevel.city:
        return PrivacyLevelInfo(
          title: 'City Level',
          description: 'Share only your city and state/province',
          icon: Icons.location_city,
        );
      case LocationPrivacyLevel.region:
        return PrivacyLevelInfo(
          title: 'Region Level',
          description: 'Share only your state/province and country',
          icon: Icons.public,
        );
      case LocationPrivacyLevel.country:
        return PrivacyLevelInfo(
          title: 'Country Only',
          description: 'Share only your country',
          icon: Icons.flag,
        );
      case LocationPrivacyLevel.hidden:
        return PrivacyLevelInfo(
          title: 'Hidden',
          description: 'Don\'t share any location information',
          icon: Icons.visibility_off,
        );
    }
  }
}

class PrivacyLevelInfo {
  final String title;
  final String description;
  final IconData icon;

  const PrivacyLevelInfo({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Simple location permission request widget
class LocationPermissionWidget extends StatefulWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const LocationPermissionWidget({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  State<LocationPermissionWidget> createState() => _LocationPermissionWidgetState();
}

class _LocationPermissionWidgetState extends State<LocationPermissionWidget> {
  final UserLocationService _locationService = UserLocationService();
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.location_on,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Location Access',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We need access to your location to help you find nearby bars and connect with other users in your area.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRequesting ? null : _requestPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isRequesting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Allow Location Access'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isRequesting ? null : () => widget.onPermissionDenied?.call(),
              child: const Text('Not Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _requestPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final result = await _locationService.requestLocationPermission();

      if (result.isGranted) {
        widget.onPermissionGranted?.call();
      } else {
        widget.onPermissionDenied?.call();

        if (mounted) {
          _showPermissionDialog(result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permission: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      widget.onPermissionDenied?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  void _showPermissionDialog(LocationPermissionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: Text(result.message),
        actions: [
          if (result.shouldShowSettings)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _locationService.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
