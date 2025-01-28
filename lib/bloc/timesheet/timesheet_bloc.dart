// timesheet_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'timesheet_event.dart';
import 'timesheet_state.dart';
import '../../services/timesheet_service.dart'; // Suppose this is DB-based now

class TimesheetBloc extends Bloc<TimesheetEvent, TimesheetState> {
  final TimesheetService timesheetService;

  TimesheetBloc({required this.timesheetService})
      : super(TimesheetState(focusedDay: DateTime.now())) {
    on<TimesheetDateSelected>(_onDateSelected);
    on<TimesheetClockInRequested>(_onClockInRequested);
    on<TimesheetClockOutRequested>(_onClockOutRequested);
  }

  // Helper to check if a day is in the past (excluding today)
  bool _isPastDay(DateTime day) {
    final now = DateTime.now();
    final dayOnly = DateTime(day.year, day.month, day.day);
    final todayOnly = DateTime(now.year, now.month, now.day);
    return dayOnly.isBefore(todayOnly);
  }

  // Helper to check if day is today
  bool _isToday(DateTime day) {
    final now = DateTime.now();
    final dayOnly = DateTime(day.year, day.month, day.day);
    final todayOnly = DateTime(now.year, now.month, now.day);
    return dayOnly == todayOnly;
  }

  // #1: Handle user tapping on a date
  Future<void> _onDateSelected(
    TimesheetDateSelected event,
    Emitter<TimesheetState> emit,
  ) async {
    final date = event.selectedDate;

    // If it's in the past (and you only want "Time done for this day")
    if (_isPastDay(date) && !_isToday(date)) {
      emit(state.copyWith(
        selectedDay: date,
        focusedDay: date,
        clockInTime: null,
        clockOutTime: null,
        // Show a message or set isDone
        message: 'Time done for this day',
        isDone: true,
      ));
      return;
    }

    // Otherwise, if it's today or future, fetch actual clock in/out times from DB (if needed)
    final clockIn = await timesheetService.getClockInTime(date);
    final clockOut = await timesheetService.getClockOutTime(date);

    emit(
      state.copyWith(
        selectedDay: date,
        focusedDay: date,
        clockInTime: clockIn,
        clockOutTime: clockOut,
        message: null,
        isDone: false,
      ),
    );
  }

  // #2: Handle user pressing "Clock In"
  Future<void> _onClockInRequested(
    TimesheetClockInRequested event,
    Emitter<TimesheetState> emit,
  ) async {
    final date = event.date;

    // If it's a past date => ignore or show an error
    if (_isPastDay(date) && !_isToday(date)) {
      return;
    }

    // Otherwise, proceed to clock in in the DB
    timesheetService.clockIn(date);

    // Retrieve the updated times
    final clockIn = await timesheetService.getClockInTime(date);
    final clockOut = await timesheetService.getClockOutTime(date);

    emit(
      state.copyWith(
        clockInTime: clockIn,
        clockOutTime: clockOut,
        message: 'Clocked in!',
      ),
    );
  }

  // #3: Handle user pressing "Clock Out"
  Future<void> _onClockOutRequested(
    TimesheetClockOutRequested event,
    Emitter<TimesheetState> emit,
  ) async {
    final date = event.date;

    // If it's a past date => ignore or show an error
    if (_isPastDay(date) && !_isToday(date)) {
      return;
    }

    // Otherwise, proceed to clock out in the DB
    timesheetService.clockOut(date);

    // Retrieve the updated times
    final clockIn = await timesheetService.getClockInTime(date);
    final clockOut = await timesheetService.getClockOutTime(date);

    emit(
      state.copyWith(
        clockInTime: clockIn,
        clockOutTime: clockOut,
        message: 'Clocked out!',
      ),
    );
  }
}
