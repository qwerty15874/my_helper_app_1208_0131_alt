import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class TtsScreen extends StatefulWidget {
  const TtsScreen({super.key});

  @override
  State<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends State<TtsScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('speaker').add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // TTS 명령이 서버로 전송되면 남은 작업 플래그를 true로 표시
      await FirebaseDatabase.instance
          .ref('status')
          .update({'tts_remain': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("초인종으로 전송했습니다! 🔊"),
          duration: Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('전송에 실패했습니다: $e')),
      );
    } finally {
      FocusScope.of(context).unfocus();
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 기본 배경은 흰색

      // [1] 상단 앱바 (흰색 배경, 검은 글씨)
      appBar: AppBar(
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
        title: Stack(
          alignment: Alignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 0),
                child: Text("말하기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 50),
              child: Image.asset('assets/bandi1.png', height: 20, fit: BoxFit.contain),
            ),
          ],
        ),
      ),

      // [2] 메인 화면
      body: Column(
        children: [
          // 2-1. 텍스트 입력 영역 (위쪽 45%) -> 흰색 배경
          Expanded(
            flex: 45,
            child: Container(
              color: Colors.white, // ★ 위쪽 배경 흰색
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _textController,
                expands: true,
                maxLines: null,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                // ★ 글자색 검정 (배경이 흰색이니까)
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
                cursorColor: Colors.black, // 커서도 검정
                decoration: const InputDecoration(
                  hintText: '말할 내용을 입력하세요',
                  hintStyle: TextStyle(color: Colors.grey), 
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // 2-2. 전송 버튼 영역 (아래쪽 55%) -> 1F1F1F 배경
          Expanded(
            flex: 55,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // ★ 아래쪽 배경색을 1F1F1F로 설정
                  backgroundColor: const Color(0xFF1F1F1F), 
                  foregroundColor: Colors.white, // 글자/아이콘은 흰색
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                onPressed: _sendMessage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 아이콘 (흰색)
                    Image.asset('assets/Frame 15.png', width: 100, height: 100, color: Colors.white),
                    const SizedBox(height: 0),
                    const Text(
                      "소리로 듣기", 
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
