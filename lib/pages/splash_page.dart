import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
    requestNotificationPermission();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Minimum splash duration

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (!mounted) return;

    if (userData != null && userData.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> requestNotificationPermission() async {
    // Check if notification permission is already granted
    var status = await Permission.notification.status;

    if (status.isDenied) {
      // Request notification permission
      status = await Permission.notification.request();

      if (status.isGranted) {
        print('Notification permission granted.');
      } else if (status.isPermanentlyDenied) {
        // The user permanently denied the permission. You can redirect them to app settings.
        print(
            'Notification permission permanently denied. Redirecting to app settings...');
        openAppSettings();
      } else {
        print('Notification permission denied.');
      }
    } else if (status.isGranted) {
      print('Notification permission is already granted.');
    } else if (status.isPermanentlyDenied) {
      print(
          'Notification permission permanently denied. Redirecting to app settings...');
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              height: 120,
              width: 120,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                'assets/images/logo.png', // Add your logo asset
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            // App Name
            Text(
              'Oasis Delivery Admin',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
