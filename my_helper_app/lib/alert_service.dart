import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

/// Listens to status alert flags and raises a local notification (with vibration if available).
class AlertService {
  AlertService._();
  static final AlertService instance = AlertService._();

  final _fln = FlutterLocalNotificationsPlugin();
  Stream<DatabaseEvent>? _sub;
  int? _lastAlertTs;

  Future<void> init() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _fln.initialize(initSettings);

    // Android 13+ 알림 권한 요청
    await _fln
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    // iOS 권한 요청
    await _fln
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void start() {
    _sub ??= FirebaseDatabase.instance.ref('status').onValue.listen((event) async {
      final val = event.snapshot.value;
      if (val is! Map) return;
      final alert = val['alert'] == true;
      final ts = _toInt(val['alert_ts']);
      if (alert && ts != null && ts != _lastAlertTs) {
        _lastAlertTs = ts;
        await _show();
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 500);
        }
      }
    });
  }

  int? _toInt(Object? v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  Future<void> _show() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'alerts',
        'Alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _fln.show(
      0,
      'MISO 알림',
      '5초 이상 움직임이 감지되었습니다.',
      details,
    );
  }
}
