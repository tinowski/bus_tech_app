import 'package:flutter/foundation.dart';

class TimesheetService {
  // In-memory storage: Key = "yyyy-MM-dd", Value = {"in": DateTime?, "out": DateTime?}
  final Map<String, Map<String, DateTime?>> _records = {};

  String _formatDateKey(DateTime date) {
    // Convert to a date-only form to ensure the key is unique for each calendar day
    final dateOnly = DateTime(date.year, date.month, date.day);
    return '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';
  }

  DateTime? getClockInTime(DateTime date) {
    final key = _formatDateKey(date);
    if (_records.containsKey(key)) {
      return _records[key]!['in'];
    }
    return null;
  }

  DateTime? getClockOutTime(DateTime date) {
    final key = _formatDateKey(date);
    if (_records.containsKey(key)) {
      return _records[key]!['out'];
    }
    return null;
  }

  void clockIn(DateTime date) {
    final key = _formatDateKey(date);
    if (!_records.containsKey(key)) {
      _records[key] = {'in': null, 'out': null};
    }
    // Store the exact time now
    _records[key]!['in'] = DateTime.now();
    debugPrint('Clocked IN on $key at ${_records[key]!['in']}');
  }

  void clockOut(DateTime date) {
    final key = _formatDateKey(date);
    if (!_records.containsKey(key)) {
      debugPrint('Error: No clock-in record for this date ($key).');
      return;
    }
    // Store the exact time now
    _records[key]!['out'] = DateTime.now();
    debugPrint('Clocked OUT on $key at ${_records[key]!['out']}');
  }
}
