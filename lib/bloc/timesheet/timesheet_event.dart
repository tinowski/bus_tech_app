import 'package:equatable/equatable.dart';

abstract class TimesheetEvent extends Equatable {
  const TimesheetEvent();

  @override
  List<Object?> get props => [];
}

class TimesheetDateSelected extends TimesheetEvent {
  final DateTime selectedDate;

  const TimesheetDateSelected(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

class TimesheetClockInRequested extends TimesheetEvent {
  final DateTime date;

  const TimesheetClockInRequested(this.date);

  @override
  List<Object?> get props => [date];
}

class TimesheetClockOutRequested extends TimesheetEvent {
  final DateTime date;

  const TimesheetClockOutRequested(this.date);

  @override
  List<Object?> get props => [date];
}
