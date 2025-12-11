import 'package:flutter/material.dart';

class ReportDoneScreen extends StatelessWidget {
  const ReportDoneScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: SizedBox(width: double.infinity, child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // ★ 위에서부터 배치 시작
        children: [
          const SizedBox(height: 150), // ★ 이 숫자를 조절해서 위치를 잡으세요 (작을수록 위로 감)
          
          Image.asset('assets/Frame 17.png', width: 120, height: 120),
          const SizedBox(height: 30),
          
          const Text("신고가 완료되었습니다.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("곧 경찰이 도착합니다.", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      )),
    );
  }
}