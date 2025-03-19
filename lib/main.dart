import 'package:admin/blocs/analytics/analytics_bloc.dart';
import 'package:admin/blocs/auth/auth_bloc.dart';
import 'package:admin/blocs/orders/order_bloc.dart';
import 'package:admin/blocs/products/product_bloc.dart';
import 'package:admin/blocs/theme/theme_bloc.dart';
import 'package:admin/blocs/theme/theme_state.dart';
import 'package:admin/helpers/theme/app_theme.dart';
import 'package:admin/pages/home_page.dart';
import 'package:admin/pages/login_page.dart';
import 'package:admin/pages/notification_page.dart';
import 'package:admin/pages/splash_page.dart';
import 'package:admin/repositories/local_auth_repository.dart';
import 'package:admin/repositories/local_order_repository.dart';
import 'package:admin/repositories/local_product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request location permission
  await _requestLocationPermission();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalOrderRepository>(
          create: (_) => LocalOrderRepository(),
        ),
        Provider<DummyProductRepository>(
          create: (_) => DummyProductRepository(),
        ),
        RepositoryProvider(
          create: (_) => LocalAuthRepository(prefs),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<OrdersBloc>(
            create: (context) => OrdersBloc(
              orderRepository: context.read<LocalOrderRepository>(),
            ),
          ),
          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(
              context.read<DummyProductRepository>(),
            ),
          ),
          BlocProvider<OrderAnalyticsBloc>(
            create: (context) => OrderAnalyticsBloc(),
          ),
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(),
          ),
          BlocProvider<ThemeBloc>(create: (context) => ThemeBloc(prefs)),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'E-commerce Dashboard',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(),
          routes: {
            '/login': (context) => LoginScreen(),
            '/home': (context) => HomePage(),
            '/notifications': (context) => NotificationPage(),
          },
          builder: (context, child) {
            final width = MediaQuery.of(context).size.width;
            final height = MediaQuery.of(context).size.height;

            ScreenUtil.init(
              context,
              designSize: Size(width, height),
            );

            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}

// Method to request location permission
Future<void> _requestLocationPermission() async {
  var status = await Permission.location.status;

  if (status.isDenied) {
    // Request location permission
    if (await Permission.location.request().isGranted) {
      print('Location permission granted');
    } else {
      print('Location permission denied');
    }
  } else if (status.isGranted) {
    print('Location permission already granted');
  } else if (status.isPermanentlyDenied) {
    print('Location permission is permanently denied');
    // Optionally guide the user to app settings
    openAppSettings();
  }
}
