import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkTimeService {
  static DateTime? _networkNow;
  static Duration? _offset;

  /// Fetches the current UTC time from worldtimeapi.org
  static Future<void> sync() async {
    final response = await http.get(Uri.parse('https://worldtimeapi.org/api/ip'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final utc = DateTime.parse(data['utc_datetime']);
      _networkNow = utc;
      _offset = utc.difference(DateTime.now().toUtc());
    }
  }

  /// Returns the current accurate time (UTC + offset)
  static DateTime now() {
    if (_networkNow != null && _offset != null) {
      return DateTime.now().toUtc().add(_offset!);
    }
    return DateTime.now();
  }
}

