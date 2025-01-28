import 'package:flutter/foundation.dart';

class TimesheetService {
  // In-memory storage: Key = "yyyy-MM-dd", Value = {"in": DateTime?, "out": DateTime?}
  final Map<String, Map<String, DateTime?>> _records = {};

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    _records[key]!['in'] = DateTime.now();
  }

  void clockOut(DateTime date) {
    final key = _formatDateKey(date);
    if (!_records.containsKey(key)) {
      debugPrint('Error: No clock-in record for this date.');
      return;
    }
    _records[key]!['out'] = DateTime.now();
  }
}
