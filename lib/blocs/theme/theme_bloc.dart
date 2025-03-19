import 'package:admin/blocs/theme/theme_event.dart';
import 'package:admin/blocs/theme/theme_state.dart';
import 'package:admin/widgets/theme_selection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;
  static const String _themeKey = 'themeMode';

  ThemeBloc(this.prefs) : super(ThemeState(themeMode: ThemeMode.system)) {
    on<InitializeTheme>((event, emit) {
      final savedThemeMode = prefs.getString(_themeKey);
      final themeMode = savedThemeMode != null
          ? ThemeMode.values.firstWhere(
              (e) => e.toString() == savedThemeMode,
              orElse: () => ThemeMode.system,
            )
          : ThemeMode.system;
      emit(ThemeState(themeMode: themeMode));
    });

    on<UpdateTheme>((event, emit) {
      prefs.setString(_themeKey, event.themeMode.toString());
      emit(ThemeState(themeMode: event.themeMode));
    });
  }
}
