import 'package:flutter/material.dart';
import 'tts_screen.dart';
import 'light_screen.dart';
import 'video_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/bandi1.png', width: 200, height: 200),
              const SizedBox(height: 40),
              _buildMenuButton(context, "말하기", const TtsScreen(), 'assets/Frame 12.png'),
              const SizedBox(height: 15),
              _buildMenuButton(context, "조명 켜기", const LightScreen(), 'assets/Frame 13.png'),
              const SizedBox(height: 15),
              _buildMenuButton(context, "영상 녹화 관리", const VideoScreen(), 'assets/Frame 14.png'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext ctx, String title, Widget page, String path) {
    return SizedBox(
      width: 300, height: 80,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, foregroundColor: Colors.white,
          alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
        icon: Image.asset(path, width: 24, height: 24, fit: BoxFit.contain),
        label: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}