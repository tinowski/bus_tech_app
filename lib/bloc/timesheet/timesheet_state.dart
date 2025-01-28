import 'package:equatable/equatable.dart';

class TimesheetState extends Equatable {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;

  const TimesheetState({
    required this.focusedDay,
    this.selectedDay,
    this.clockInTime,
    this.clockOutTime,
  });

  TimesheetState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    DateTime? clockInTime,
    DateTime? clockOutTime,
  }) {
    return TimesheetState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
    );
  }

  @override
  List<Object?> get props => [focusedDay, selectedDay, clockInTime, clockOutTime];
}

