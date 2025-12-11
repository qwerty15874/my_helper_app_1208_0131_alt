import 'package:flutter/material.dart';
import 'third_light_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LightScreen extends StatelessWidget {
  const LightScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, titleSpacing: 0,
        title: Stack(alignment: Alignment.center, children: [
          const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 0), child: Text("조명 켜기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
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
              // 오른쪽 조명 활성화 신호 보냄
              FirebaseFirestore.instance.collection('iot').doc('light_control').set({
                'right_on': true, 
              }, SetOptions(merge: true)); // 다른 값은 건드리지 않음
            },
            label: const Text("조명 켜기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 20),
          SizedBox(width: 300, height: 80, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThirdLightScreen())),
            child: const Text("3차 조명 켜기 >", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
        ])),
      ]),
    );
  }
}