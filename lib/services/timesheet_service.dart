class TimesheetService {
  final Map<String, Map<String, DateTime?>> _records = {};

  String _formatDateKey(DateTime date) {
    // Returns something like "2025-03-10" for day-only uniqueness
    final dayOnly = DateTime(date.year, date.month, date.day);
    return '${dayOnly.year}-${dayOnly.month.toString().padLeft(2, '0')}-${dayOnly.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime? getClockInTime(DateTime date) {
    final key = _formatDateKey(date);
    return _records[key]?['in'];
  }

  DateTime? getClockOutTime(DateTime date) {
    final key = _formatDateKey(date);
    return _records[key]?['out'];
  }

  void clockIn(DateTime selectedDate) {
    final key = _formatDateKey(selectedDate);
    _records[key] ??= {'in': null, 'out': null};

    // If the selected date is "today," store the actual current time
    final now = DateTime.now();
    if (_isSameDay(selectedDate, now)) {
      _records[key]!['in'] = DateTime.now();
    } else {
      // Otherwise, we trust the 'selectedDate' that came from user input
      // which might include hour & minute (if you used a time picker).
      _records[key]!['in'] = selectedDate;
    }
  }

  void clockOut(DateTime selectedDate) {
    final key = _formatDateKey(selectedDate);
    if (!_records.containsKey(key)) {
      return;
    }

    // Same logic for clock out:
    final now = DateTime.now();
    if (_isSameDay(selectedDate, now)) {
      _records[key]!['out'] = DateTime.now();
    } else {
      _records[key]!['out'] = selectedDate;
    }
  }
}
