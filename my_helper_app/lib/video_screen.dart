import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  String formatTs(int? ts) {
    if (ts == null) return "날짜 정보 없음";
    return DateFormat('yyyy년 MM월 dd일 HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(ts * 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0, // 타이틀 영역 여백 제거 (최대한 왼쪽으로 붙임)
        title: Stack(
          alignment: Alignment.center,
          children: [
            // [1] 왼쪽 텍스트 (위치 조절 적용)
            Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                // ★ offset: Offset(x, y) -> x값을 음수로 주면 왼쪽으로 이동합니다.
                // -5, -10 등으로 숫자를 바꿔서 원하는 위치를 잡으세요.
                offset: const Offset(-5, 0), 
                child: const Text(
                  "영상 목록", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),
            
            // [2] 가운데 미소 로고
            Padding(
              // 로고가 정중앙보다 오른쪽으로 치우쳐 보이면 이 숫자를 늘리세요 (예: 45.0 -> 50.0)
              padding: const EdgeInsets.only(right: 45.0), 
              child: Align(
                alignment: Alignment.center,
                child: Image.asset('assets/bandi1.png', height: 20, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.delete_outline),
        label: const Text("영상 전체 삭제"),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("전체 삭제"),
              content: const Text("모든 녹화 목록을 삭제할까요? (되돌릴 수 없음)"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("취소")),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("삭제", style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirmed == true) {
            try {
              await FirebaseDatabase.instance.ref('events').remove();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("영상 목록을 모두 삭제했습니다.")),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("삭제 실패: $e")),
                );
              }
            }
          }
        },
      ),
      body: StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance.ref('events').onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
              return const Center(child: Text("저장된 영상이 없습니다.", style: TextStyle(color: Colors.grey)));
            }
            final raw = snapshot.data!.snapshot.value as Map;
            final items = raw.entries.map((e) {
              final m = (e.value as Map).map((k, v) => MapEntry(k.toString(), v));
              return {
                'url': m['url'] ?? '',
                'path': m['path'] ?? '',
                'timestamp': (m['timestamp'] is int) ? m['timestamp'] as int : int.tryParse('${m['timestamp']}'),
              };
            }).toList();
            items.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

            if (items.isEmpty) {
              return const Center(child: Text("저장된 영상이 없습니다.", style: TextStyle(color: Colors.grey)));
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final data = items[index];
                final url = data['url'] ?? '';
                final ts = data['timestamp'];
                final filename = data['path'] ?? '알 수 없는 파일';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(backgroundColor: Colors.black12, child: Icon(Icons.play_arrow, color: Colors.black)),
                    title: Text(formatTs(ts), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(filename, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      if (url.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(url: url, filename: filename)));
                    },
                  ),
                );
              },
            );
          }),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  final String url;
  final String filename;
  const PlayerScreen({super.key, required this.url, required this.filename});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _vc;
  ChewieController? _cc;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _vc = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _vc.initialize();
      setState(() {
        _cc = ChewieController(videoPlayerController: _vc, autoPlay: true, looping: false, aspectRatio: _vc.value.aspectRatio);
      });
    } catch (e) { print("Error: $e"); }
  }

  @override
  void dispose() {
    _vc.dispose();
    _cc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.filename), backgroundColor: Colors.transparent, foregroundColor: Colors.white),
      body: Center(
        child: _cc != null && _vc.value.isInitialized ? Chewie(controller: _cc!) : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
