// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../bloc/timesheet/timesheet_bloc.dart';
import '../bloc/timesheet/timesheet_event.dart';
import '../bloc/timesheet/timesheet_state.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({Key? key}) : super(key: key);

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  // For displaying hour:minute only
  final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    // Optionally select today's date by default:
    context.read<TimesheetBloc>().add(TimesheetDateSelected(DateTime.now()));
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheet'),
      ),
      drawer: _buildDrawer(context),
      body: BlocBuilder<TimesheetBloc, TimesheetState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildCalendar(state),
              const SizedBox(height: 16),
              _buildDayDetails(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            // Header
            const ListTile(
              title: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),

            // Timesheets Option
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Timesheets'),
              onTap: () {
                // Close the drawer
                Navigator.pop(context);
                // If you want to navigate to the same screen,
                // you can do so, but typically you'd just pop
                // to close the drawer if you're already on Timesheets.
              },
            ),

            // Settings Option
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Close the drawer
                Navigator.pop(context);
                // Navigate to the Settings screen
                Navigator.pushNamed(context, '/settings');
              },
            ),

            // Logout Option
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Close the drawer
                Navigator.pop(context);
                // For example, if you have an AuthBloc:
                // context.read<AuthBloc>().add(AuthLogoutRequested());
                // Then navigate to login screen
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
        // **Dispatch** TimesheetDateSelected with the actual day tapped
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
      calendarStyle: const CalendarStyle(
        isTodayHighlighted: true,
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

    if (_isPastDay(selectedDay) && !_isToday(selectedDay)) {
      return Text(state.message ?? 'Time done for this day');
    } else if (_isFutureDay(selectedDay)) {
      // Future day
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Future date — no entry allowed',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else if (_isToday(selectedDay)) {
      // Today
      return _buildTodayTimes(clockInTime, clockOutTime, selectedDay);
    }
    // Fallback
    return const SizedBox.shrink();
  }

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
            Text('Clock In: ${_formatTime(clockInTime)}'),
            Text('Clock Out: ${_formatTime(clockOutTime)}'),
          ],
        ),
      ),
    );
  }

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
                  // **Use the exact selectedDay** from the state
                  context
                      .read<TimesheetBloc>()
                      .add(TimesheetClockInRequested(day));
                },
                child: const Text('Clock In'),
              )
            else
              Text('Clock In: ${_formatTime(clockInTime)}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (clockInTime != null && clockOutTime == null)
              ElevatedButton(
                onPressed: () {
                  context
                      .read<TimesheetBloc>()
                      .add(TimesheetClockOutRequested(day));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Clock Out'),
              )
            else if (clockOutTime != null)
              Text('Clock Out: ${_formatTime(clockOutTime)}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '---';
    return _timeFormat.format(dt);
  }
}
