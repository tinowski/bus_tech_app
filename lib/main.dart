import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/auth_service.dart';
import 'services/timesheet_service.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/timesheet/timesheet_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/timesheet_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final timesheetService = TimesheetService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authService: authService),
        ),
        BlocProvider(
          create: (_) => TimesheetBloc(timesheetService: timesheetService),
        ),
      ],
      child: MaterialApp(
        title: 'Timesheets App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/timesheet': (context) => const TimesheetScreen(),
        },
      ),
    );
  }
}
