import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/timesheet/timesheet_bloc.dart';
import '../bloc/timesheet/timesheet_event.dart';
import '../bloc/timesheet/timesheet_state.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  @override
  void initState() {
    super.initState();
    // Optionally, set initial date selection (today)
    final now = DateTime.now();
    context.read<TimesheetBloc>().add(TimesheetDateSelected(now));
  }

  bool _isPastDay(DateTime day) {
    final now = DateTime.now();
    return day.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  bool _isFutureDay(DateTime day) {
    final now = DateTime.now();
    return day.isAfter(DateTime(now.year, now.month, now.day));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // If user somehow not authenticated, go to login
        if (authState is! AuthAuthenticated) {
          // Force user to login
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
      selectedDayPredicate: (day) => day.day == state.selectedDay?.day &&
          day.month == state.selectedDay?.month &&
          day.year == state.selectedDay?.year,
      calendarFormat: CalendarFormat.month,
      onDaySelected: (selectedDay, focusedDay) {
        if (!_isFutureDay(selectedDay)) {
          context.read<TimesheetBloc>().add(TimesheetDateSelected(selectedDay));
        }
      },
      // We'll limit user from tapping future days with table_calendar style:
      enabledDayPredicate: (day) => !_isFutureDay(day),
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        // Slight customization for a modern look
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

    if (_isPastDay(selectedDay) && !_isToday(selectedDay)) {
      // Past day: read only
      return _buildReadOnlyTimes(clockInTime, clockOutTime, selectedDay);
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
              'Times for ${day.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Clock In: ${clockInTime != null ? clockInTime.toLocal() : '---'}'),
            Text('Clock Out: ${clockOutTime != null ? clockOutTime.toLocal() : '---'}'),
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
              'Today: ${day.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (clockInTime == null)
              ElevatedButton(
                onPressed: () {
                  context.read<TimesheetBloc>().add(TimesheetClockInRequested(day));
                },
                child: const Text('Clock In'),
              )
            else
              Text(
                'Clock In: ${clockInTime.toLocal()}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 12),
            if (clockInTime != null && clockOutTime == null)
              ElevatedButton(
                onPressed: () {
                  context.read<TimesheetBloc>().add(TimesheetClockOutRequested(day));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Clock Out'),
              )
            else if (clockOutTime != null)
              Text(
                'Clock Out: ${clockOutTime.toLocal()}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}
