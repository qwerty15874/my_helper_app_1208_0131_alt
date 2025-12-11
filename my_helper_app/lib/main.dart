import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'alert_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 플러터 설정 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // 파이어베이스 연결

  // RTDB alert 플래그를 듣고 로컬 알림/진동 표시
  await AlertService.instance.init();
  AlertService.instance.start();

  // ★ 이 코드가 있어야만 토큰이 보입니다!
  final fcmToken = await FirebaseMessaging.instance.getToken();
  // ignore: avoid_print
  print("============================================");
  // ignore: avoid_print
  print("내 폰 토큰: $fcmToken");
  // ignore: avoid_print
  print("============================================");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '반디',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      home: const HomeScreen(),
      routes: {
        // 상태 확인용 별도 화면 (기존 UI와 디자인은 그대로 유지)
        '/status': (_) => const StatusPage(),
      },
    );
  }
}

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref('status');
    return Scaffold(
      appBar: AppBar(title: const Text('MISO 상태')),
      body: StreamBuilder<DatabaseEvent>(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = (snapshot.data!.snapshot.value as Map).map(
            (k, v) => MapEntry(k.toString(), v),
          );
          final tracking = data['tracking'] == true;
          final detected = data['person_detected'] == true;
          final mainLight = data['main_light'] == true;
          final subLight = data['sub_light'] == true;
          final lastUpdate = data['last_update']?.toString() ?? '-';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusTile('추적', tracking),
                _StatusTile('사람 감지', detected),
                _StatusTile('메인 조명', mainLight),
                _StatusTile('서브 조명', subLight),
                const SizedBox(height: 12),
                Text('last_update: $lastUpdate'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String label;
  final bool on;
  const _StatusTile(this.label, this.on);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Icon(
        on ? Icons.circle : Icons.circle_outlined,
        color: on ? Colors.greenAccent : Colors.grey,
      ),
    );
  }
}
