import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:rise_up/managers/notification_manager.dart';

class AppController {
  static final instance = AppController._();
  AppController._();

  final notifications = NotificationManager();

  Future<void> init() async {
    await notifications.init();
    await _requestPermissions();

    final exactAlarmGranted = await _checkExactAlarmPermission();
    if (!exactAlarmGranted) {
      await openExactAlarmSettings();
      return;
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<bool> _checkExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      return true;
    } else {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    }
  }

  Future<void> openExactAlarmSettings() async {
    if (Platform.isAndroid) {
      const androidSettingsUri = 'android.settings.SCHEDULE_EXACT_ALARM';
      final uri = Uri(
        scheme: 'package',
        path: androidSettingsUri,
        queryParameters: {},
      );
      if (!await launchUrl(uri)) {}
    }
  }
}
