import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'report_done_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThirdLightScreen extends StatelessWidget {
  const ThirdLightScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, titleSpacing: 0,
        title: Stack(alignment: Alignment.center, children: [
          const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 0), child: Text("3차 조명 켜기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
          Padding(padding: const EdgeInsets.only(right: 50), child: Image.asset('assets/bandi1.png', height: 20)),
        ]),
      ),
      body: Column(children: [
        const SizedBox(height: 0),
        Image.asset('assets/light3.png', width: 300, height: 300),
        const SizedBox(height: 20),
        Center(child: Column(children: [
          SizedBox(width: 300, height: 80, child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
            onPressed: () {
              // 왼쪽 조명 활성화 신호 보냄
              FirebaseFirestore.instance.collection('iot').doc('light_control').set({
                'left_on': true, 
              }, SetOptions(merge: true));
            },
            label: const Text("조명 켜기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 20),
          SizedBox(width: 300, height: 80, child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDCC02), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
            
            // ★ 버튼 누르면 신고 완료 화면으로 이동
            onPressed: () async {
              // 전화번호 (테스트용 내 번호)
              const number = '01076003541'; 
              
              // 바로 전화 걸기 시도
              bool? res = await FlutterPhoneDirectCaller.callNumber(number);
              
              // 화면 이동
              if (context.mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportDoneScreen()));
              }
            },
            
            icon: Image.asset('assets/Frame 16.png', width: 30, height: 30),
            label: const Text("경찰에 신고하기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
        ])),
      ]),
    );
  }
}