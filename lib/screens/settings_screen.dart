import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings/settings_cubit.dart';
import '../bloc/settings/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Select Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<Locale>(
                  value: settingsState.locale,
                  onChanged: (newLocale) {
                    if (newLocale != null) {
                      context.read<SettingsCubit>().changeLocale(newLocale);
                    }
                  },
                  items: supportedLocales.map((locale) {
                    return DropdownMenuItem<Locale>(
                      value: locale,
                      // For label, we can simply use the 'languageCode'
                      // or map it to a more user-friendly name
                      child: Text(_localeToLanguageName(locale)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _localeToLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'fr':
        return 'Français';
      default:
        return locale.languageCode;
    }
  }
}
