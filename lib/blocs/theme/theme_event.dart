import 'package:admin/widgets/theme_selection.dart';

abstract class ThemeEvent {}

class UpdateTheme extends ThemeEvent {
  final ThemeMode themeMode;
  UpdateTheme(this.themeMode);
}

class InitializeTheme extends ThemeEvent {}
