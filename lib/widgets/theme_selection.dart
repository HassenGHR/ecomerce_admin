// theme_selection_sheet.dart
import 'package:admin/blocs/theme/theme_bloc.dart';
import 'package:admin/blocs/theme/theme_event.dart';
import 'package:admin/blocs/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ThemeMode {
  system,
  light,
  dark,
}

class ThemeSelectionSheet extends StatelessWidget {
  const ThemeSelectionSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Column(
                children: ThemeMode.values.map((mode) {
                  String title;
                  String subtitle;
                  IconData icon;

                  switch (mode) {
                    case ThemeMode.system:
                      title = 'System';
                      subtitle = 'Follow system settings';
                      icon = Icons.brightness_auto;
                      break;
                    case ThemeMode.light:
                      title = 'Light';
                      subtitle = 'Light theme';
                      icon = Icons.light_mode_rounded;
                      break;
                    case ThemeMode.dark:
                      title = 'Dark';
                      subtitle = 'Dark theme';
                      icon = Icons.dark_mode_rounded;
                      break;
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildThemeOption(
                      context: context,
                      title: title,
                      subtitle: subtitle,
                      icon: icon,
                      isSelected: state.themeMode == mode,
                      onTap: () {
                        context.read<ThemeBloc>().add(UpdateTheme(mode));
                        Navigator.pop(context);
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 24.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
