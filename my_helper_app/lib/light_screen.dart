import 'package:flutter/material.dart';
import 'third_light_screen.dart';
import 'command_service.dart';

class LightScreen extends StatefulWidget {
  const LightScreen({super.key});

  @override
  State<LightScreen> createState() => _LightScreenState();
}

class _LightScreenState extends State<LightScreen> {
  bool _mainOn = false;
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
              setState(() => _mainOn = !_mainOn);
              CommandService.setMainLight(_mainOn);
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
