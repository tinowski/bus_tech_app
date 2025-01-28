import 'package:flutter_bloc/flutter_bloc.dart';
import 'timesheet_event.dart';
import 'timesheet_state.dart';
import '../../services/timesheet_service.dart';

class TimesheetBloc extends Bloc<TimesheetEvent, TimesheetState> {
  final TimesheetService timesheetService;

  TimesheetBloc({required this.timesheetService})
      : super(TimesheetState(focusedDay: DateTime.now())) {
    on<TimesheetDateSelected>(_onDateSelected);
    on<TimesheetClockInRequested>(_onClockInRequested);
    on<TimesheetClockOutRequested>(_onClockOutRequested);
  }

  void _onDateSelected(
    TimesheetDateSelected event,
    Emitter<TimesheetState> emit,
  ) {
    final clockIn = timesheetService.getClockInTime(event.selectedDate);
    final clockOut = timesheetService.getClockOutTime(event.selectedDate);

    emit(state.copyWith(
      selectedDay: event.selectedDate,
      focusedDay: event.selectedDate,
      clockInTime: clockIn,
      clockOutTime: clockOut,
    ));
  }

  void _onClockInRequested(
    TimesheetClockInRequested event,
    Emitter<TimesheetState> emit,
  ) {
    timesheetService.clockIn(event.date);

    final clockIn = timesheetService.getClockInTime(event.date);
    final clockOut = timesheetService.getClockOutTime(event.date);

    emit(state.copyWith(clockInTime: clockIn, clockOutTime: clockOut));
  }

  void _onClockOutRequested(
    TimesheetClockOutRequested event,
    Emitter<TimesheetState> emit,
  ) {
    timesheetService.clockOut(event.date);

    final clockIn = timesheetService.getClockInTime(event.date);
    final clockOut = timesheetService.getClockOutTime(event.date);

    emit(state.copyWith(clockInTime: clockIn, clockOutTime: clockOut));
  }
}
