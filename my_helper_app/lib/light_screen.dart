import 'package:flutter/material.dart';
import 'third_light_screen.dart';
import 'command_service.dart';
import 'package:firebase_database/firebase_database.dart';

class LightScreen extends StatefulWidget {
  const LightScreen({super.key});

  @override
  State<LightScreen> createState() => _LightScreenState();
}

class _LightScreenState extends State<LightScreen> {
  bool _mainOn = false;

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref('status').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val is Map) {
        setState(() {
          _mainOn = val['main_light'] == true;
        });
      }
    });
  }
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
        Image.asset(
          _mainOn ? 'assets/light.png' : 'assets/light1.png',
          width: 300,
          height: 300,
        ),
        const SizedBox(height: 15),
        Center(child: Column(children: [
          SizedBox(width: 300, height: 80, child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F1F1F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
            onPressed: () {
              setState(() => _mainOn = !_mainOn);
              CommandService.setMainLight(_mainOn);
            },
            label: const Text("조명 켜기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 15),
          SizedBox(
            width: 300,
            height: 80,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF1F1F1F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              ),
              onPressed: () {
                setState(() => _mainOn = false);
                CommandService.setMainLight(false);
              },
              child: const Text("조명 끄기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(width: 300, height: 80, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F1F1F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThirdLightScreen())),
            child: const Text("보조 조명 켜기 >", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
        ])),
      ]),
      floatingActionButton: _mainOn
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.power_settings_new),
              label: const Text("모두 끄기"),
              onPressed: () {
                setState(() => _mainOn = false);
                CommandService.setMainLight(false);
                CommandService.setSubLight(false);
              },
            )
          : null,
    );
  }
}
