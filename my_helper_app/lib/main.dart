import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_helper_app/firebase_options.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 플러터 설정 초기화
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);            // 파이어베이스 연결

  // ★ 이 코드가 있어야만 토큰이 보입니다!
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("============================================");
  print("내 폰 토큰: $fcmToken"); 
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
    );
  }
}

