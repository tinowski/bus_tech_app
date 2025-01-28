import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/settings/settings_state.dart';
import 'bloc/timesheet/timesheet_bloc.dart';
import 'bloc/settings/settings_cubit.dart';
import 'services/auth_service.dart';
import 'services/timesheet_service.dart';
import 'screens/login_screen.dart';
import 'screens/timesheet_screen.dart';
import 'screens/settings_screen.dart';

// For localization delegates:
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        BlocProvider(
          create: (_) => SettingsCubit(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'Timesheets App',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            ),
            locale: settingsState.locale, // <-- Critical
            supportedLocales: const [
              Locale('en'),
              Locale('es'),
            ],
            // Provide Flutter's built-in localizations (so that e.g. Material strings change):
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/timesheet': (context) => const TimesheetScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
