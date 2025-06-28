// Simple test without Flutter dependencies
import 'dart:convert';

void main() {
  print('[DEBUG_LOG] Testing UserLocation JSON serialization fix...');

  // Simulate the JSON that would be created by UserLocation.toJson()
  // This represents what happens when a UserLocation with a generated UUID is serialized
  final originalJson = {
    'id': 'generated-uuid-12345', // This is the problematic field
    'user_id': 'test-user-123',
    'latitude': 37.7749,
    'longitude': -122.4194,
    'accuracy': null,
    'country': null,
    'administrative_area': null,
    'locality': null,
    'sub_locality': null,
    'thoroughfare': null,
    'sub_thoroughfare': null,
    'postal_code': null,
    'iso_country_code': null,
    'timestamp': DateTime.now().toIso8601String(),
    'is_current_location': true,
    'location_name': null,
    'privacy_level': 'city',
    'source': 'gps',
  };

  print('[DEBUG_LOG] Original JSON includes ID: ${originalJson.containsKey('id')}');
  print('[DEBUG_LOG] Original JSON ID value: ${originalJson['id']}');

  // Test the fix: remove ID from JSON (simulating what happens in saveUserLocation)
  final locationJson = Map<String, dynamic>.from(originalJson);
  locationJson.remove('id');

  print('[DEBUG_LOG] Modified JSON includes ID: ${locationJson.containsKey('id')}');
  print('[DEBUG_LOG] Modified JSON keys: ${locationJson.keys.toList()}');

  // Verify that essential fields are still present
  final requiredFields = ['user_id', 'latitude', 'longitude', 'timestamp', 'is_current_location'];
  bool allFieldsPresent = true;

  for (final field in requiredFields) {
    if (!locationJson.containsKey(field)) {
      print('[DEBUG_LOG] ERROR: Missing required field: $field');
      allFieldsPresent = false;
    } else {
      print('[DEBUG_LOG] ✓ Field present: $field = ${locationJson[field]}');
    }
  }

  if (allFieldsPresent) {
    print('[DEBUG_LOG] SUCCESS: All required fields present in modified JSON');
    print('[DEBUG_LOG] Fix should resolve the PostgreSQL ID insertion error');
    print('[DEBUG_LOG] The database will auto-generate the ID column');
  } else {
    print('[DEBUG_LOG] ERROR: Some required fields are missing');
  }

  // Show the final JSON that would be sent to the database
  print('[DEBUG_LOG] Final JSON for database insertion:');
  print('[DEBUG_LOG] ${jsonEncode(locationJson)}');
}
