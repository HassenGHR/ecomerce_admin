import 'package:admin/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:admin/models/notification_model.dart';
import 'package:admin/pages/home_page.dart';
import 'dart:ui' as ui;

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<NotificationModel> notifications =
        _generateStaticNotifications();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text('الإشعارات', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
      ),
      body: notifications.isEmpty
          ? _buildEmptyWidget(theme)
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(context, notifications[index]);
              },
            ),
    );
  }

  static List<NotificationModel> _generateStaticNotifications() {
    return [
      NotificationModel(
        id: '1',
        userId: '123',
        title: 'طلب جديد',
        body: 'لديك طلب جديد من العميل محمد.',
        user: UserModel(
            id: '123',
            name: 'محمد',
            email: 'mohamed@example.com',
            phone: '0123456789',
            address: 'الجزائر',
            token: '',
            imageUrl: ''),
        isRead: false,
        time: DateTime.now().subtract(Duration(minutes: 10)),
      ),
      NotificationModel(
        id: '2',
        userId: '456',
        title: 'تم تحديث الطلب',
        body: 'تم تحديث حالة طلبك.',
        user: UserModel(
            id: '456',
            name: 'أحمد',
            email: 'ahmed@example.com',
            phone: '0987654321',
            address: 'وهران',
            token: '',
            imageUrl: ''),
        isRead: true,
        time: DateTime.now().subtract(Duration(hours: 1)),
      ),
    ];
  }

  static Widget _buildEmptyWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64.sp, color: theme.iconTheme.color?.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text('لا توجد إشعارات متاحة.', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  static Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: notification.isRead
                ? theme.primaryColor.withOpacity(0.3)
                : theme.primaryColor,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  backgroundImage: notification.user.imageUrl.isEmpty
                      ? const NetworkImage(
                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png")
                      : NetworkImage(notification.user.imageUrl),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body,
                          textDirection: ui.TextDirection.rtl,
                          style: theme.textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      Text(_calculateTimeDifference(notification.time),
                          style: theme.textTheme.labelMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _calculateTimeDifference(DateTime targetDate) {
    final difference = DateTime.now().difference(targetDate);
    if (difference.inMinutes == 0) return 'الآن';
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
    if (difference.inHours < 72) return 'منذ ${difference.inHours} ساعة';
    return 'منذ ${difference.inDays} يوم';
  }
}
