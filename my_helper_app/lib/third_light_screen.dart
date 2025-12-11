import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'report_done_screen.dart';
import 'command_service.dart';
import 'package:firebase_database/firebase_database.dart';

class ThirdLightScreen extends StatelessWidget {
  const ThirdLightScreen({super.key});
  static bool _subOn = false; // simple toggle state shared across rebuilds
  static bool _mainOn = false;

  void _listenStatus() {
    FirebaseDatabase.instance.ref('status').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val is Map) {
        _subOn = val['sub_light'] == true;
        _mainOn = val['main_light'] == true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenStatus();
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
              _subOn = !_subOn;
              CommandService.setSubLight(_subOn);
            },
            label: const Text("조명 켜기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 12),
          SizedBox(
            width: 300,
            height: 60,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                _subOn = false;
                CommandService.setSubLight(false);
              },
              child: const Text("조명 끄기", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
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
      floatingActionButton: (_mainOn || _subOn)
          ? FloatingActionButton.extended(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.power_settings_new),
              label: const Text("모두 끄기"),
              onPressed: () {
                _subOn = false;
                CommandService.setSubLight(false);
                CommandService.setMainLight(false);
              },
            )
          : null,
    );
  }
}
