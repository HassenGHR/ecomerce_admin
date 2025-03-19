import 'package:admin/blocs/theme/theme_bloc.dart';
import 'package:admin/blocs/theme/theme_event.dart';
import 'package:admin/widgets/analytics_section.dart';
import 'package:admin/widgets/theme_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:admin/models/user_model.dart';
import 'package:admin/pages/customers_page.dart';
import 'package:admin/pages/home_page.dart';
import 'package:admin/pages/orders_page.dart';
import 'package:admin/pages/splash_page.dart';
import 'package:admin/repositories/local_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModernMenuScreen extends StatelessWidget {
  final UserModel user;
  ModernMenuScreen({Key? key, required this.user}) : super(key: key);

  // Static user data
  final String imgUrl =
      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";

  void _navigateToProfile() async {
    // Profile navigation implementation
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Profile
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _navigateToProfile(),
                    child: Hero(
                      tag: 'profile_image',
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: AssetImage("assets/images/logo.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          user.phone,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                children: [
                  _buildMenuCategory(
                    context: context,
                    title: "Main Menu",
                    items: [
                      MenuItemData(
                        icon: Icons.home_rounded,
                        title: 'Home',
                        color: theme.colorScheme.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        ),
                      ),
                      MenuItemData(
                        icon: Icons.dashboard_rounded,
                        title: 'Dashboard',
                        color: theme.colorScheme.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AnalyticsSection()),
                        ),
                      ),
                      MenuItemData(
                        icon: Icons.groups,
                        title: 'Customers',
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomersScreen(),
                            ),
                          );
                        },
                      ),
                      MenuItemData(
                        icon: Icons.shopping_bag_rounded,
                        title: 'Orders',
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmedOrders(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  _buildMenuCategory(
                    context: context,
                    title: "Settings",
                    items: [
                      MenuItemData(
                        icon: Icons.brightness_6_rounded,
                        title: 'Theme Mode',
                        color: Colors.purple,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const ThemeSelectionSheet(),
                          );
                        },
                      ),
                      MenuItemData(
                        icon: Icons.exit_to_app_rounded,
                        title: 'Logout',
                        color: theme.colorScheme.error,
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final _repo = LocalAuthRepository(prefs);

                          // Sign out the user
                          await _repo.signOut();

                          // Navigate to the splash screen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SplashScreen(), // Replace with your splash screen widget
                            ),
                            (Route<dynamic> route) =>
                                false, // This removes all previous routes from the stack
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCategory(
      {required String title,
      required List<MenuItemData> items,
      required BuildContext context}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.w, bottom: 15.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              width: 2.w, // Responsive border width
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children:
                items.map((item) => _buildMenuItem(item, context)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(MenuItemData item, BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1.w,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.iconTheme.color,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}
