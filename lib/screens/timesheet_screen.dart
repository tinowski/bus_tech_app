import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/timesheet/timesheet_bloc.dart';
import '../bloc/timesheet/timesheet_event.dart';
import '../bloc/timesheet/timesheet_state.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({Key? key}) : super(key: key);

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  // Use a DateFormat to show only hour:minute (24-hour, e.g. "13:45")
  final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    // Select today's date by default
    final now = DateTime.now();
    context.read<TimesheetBloc>().add(TimesheetDateSelected(now));
  }

  /// Convert any [DateTime] to a date-only form (year, month, day).
  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isPastDay(DateTime day) {
    final today = _dateOnly(DateTime.now());
    final compareDay = _dateOnly(day);
    return compareDay.isBefore(today);
  }

  bool _isToday(DateTime day) {
    final today = _dateOnly(DateTime.now());
    final compareDay = _dateOnly(day);
    return compareDay == today;
  }

  bool _isFutureDay(DateTime day) {
    final today = _dateOnly(DateTime.now());
    final compareDay = _dateOnly(day);
    return compareDay.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // If user is not authenticated, redirect to login
        if (authState is! AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Timesheet'),
          ),
          drawer: _buildDrawer(context),
          body: BlocBuilder<TimesheetBloc, TimesheetState>(
            builder: (context, timesheetState) {
              return Column(
                children: [
                  _buildCalendar(timesheetState),
                  const SizedBox(height: 16),
                  _buildDayDetails(timesheetState),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const ListTile(
              title: Text(
                'Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Timesheets'),
              onTap: () {
                Navigator.pop(context); // just close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // close the drawer
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Dispatch logout event
                context.read<AuthBloc>().add(AuthLogoutRequested());
                // Navigate to login
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(TimesheetState state) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2050, 12, 31),
      focusedDay: state.focusedDay,
      selectedDayPredicate: (day) {
        if (state.selectedDay == null) return false;
        final selected = _dateOnly(state.selectedDay!);
        final current = _dateOnly(day);
        return selected == current;
      },
      calendarFormat: CalendarFormat.month,
      onDaySelected: (selectedDay, focusedDay) {
        // Only allow selection if day is not in the future
        if (!_isFutureDay(selectedDay)) {
          context.read<TimesheetBloc>().add(TimesheetDateSelected(selectedDay));
        }
      },
      enabledDayPredicate: (day) => !_isFutureDay(day),
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        selectedDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blueGrey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildDayDetails(TimesheetState state) {
    final selectedDay = state.selectedDay;
    if (selectedDay == null) {
      return const Text('No day selected.');
    }

    final clockInTime = state.clockInTime;
    final clockOutTime = state.clockOutTime;

    // Past day (excluding today):
    if (_isPastDay(selectedDay) && !_isToday(selectedDay)) {
      return _buildReadOnlyTimes(clockInTime, clockOutTime, selectedDay);
    }
    // Future day:
    else if (_isFutureDay(selectedDay)) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Future date — no entry allowed',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    // Today:
    else if (_isToday(selectedDay)) {
      return _buildTodayTimes(clockInTime, clockOutTime, selectedDay);
    }
    // Fallback:
    return const SizedBox.shrink();
  }

  /// Shows read-only clock in/out times for a past day.
  Widget _buildReadOnlyTimes(
      DateTime? clockInTime, DateTime? clockOutTime, DateTime day) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Times for ${_dateOnly(day).toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Clock In: ${clockInTime != null ? _timeFormat.format(clockInTime) : '---'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Clock Out: ${clockOutTime != null ? _timeFormat.format(clockOutTime) : '---'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows interactive clock in/out for the current day.
  Widget _buildTodayTimes(
      DateTime? clockInTime, DateTime? clockOutTime, DateTime day) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Today: ${_dateOnly(day).toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (clockInTime == null)
              ElevatedButton(
                onPressed: () {
                  context
                      .read<TimesheetBloc>()
                      .add(TimesheetClockInRequested(day));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: const Text('Clock In'),
              )
            else
              Text(
                'Clock In: ${_timeFormat.format(clockInTime)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 12),
            if (clockInTime != null && clockOutTime == null)
              ElevatedButton(
                onPressed: () {
                  context
                      .read<TimesheetBloc>()
                      .add(TimesheetClockOutRequested(day));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
                child: const Text('Clock Out'),
              )
            else if (clockOutTime != null)
              Text(
                'Clock Out: ${_timeFormat.format(clockOutTime)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}
