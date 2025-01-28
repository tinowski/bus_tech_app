import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(
          // Default to English if nothing is set
          const SettingsState(locale: Locale('en')),
        );

  // Update the current locale
  void changeLocale(Locale newLocale) {
    emit(state.copyWith(locale: newLocale));
  }
}
