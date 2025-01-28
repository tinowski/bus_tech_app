// timesheet_state.dart
import 'package:equatable/equatable.dart';

class TimesheetState extends Equatable {
  final DateTime focusedDay;
  final DateTime? selectedDay;

  final DateTime? clockInTime;
  final DateTime? clockOutTime;

  // Optional: a message to display in the UI (e.g. "Time done for this day")
  final String? message;

  // Indicates if the timesheet for the selected day is complete (used for past days)
  final bool isDone;

  const TimesheetState({
    required this.focusedDay,
    this.selectedDay,
    this.clockInTime,
    this.clockOutTime,
    this.message,
    this.isDone = false,
  });

  TimesheetState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    String? message,
    bool? isDone,
  }) {
    return TimesheetState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      message: message,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  List<Object?> get props => [
        focusedDay,
        selectedDay,
        clockInTime,
        clockOutTime,
        message,
        isDone,
      ];
}
