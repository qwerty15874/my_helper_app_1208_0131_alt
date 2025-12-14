import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  // 날짜 포맷팅 (그리드용으로 두 줄 처리 추천)
  String formatTs(int? ts) {
    if (ts == null) return "날짜 없음";
    return DateFormat('MM/dd\nHH:mm').format( // 월/일 (줄바꿈) 시:분
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
        titleSpacing: 0,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: const Offset(-5, 0),
                child: const Text(
                  "영상 목록",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Padding(
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
        label: const Text("전체 삭제"),
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("영상 목록을 모두 삭제했습니다.")));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("삭제 실패: $e")));
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
              return const Center(child: Text("저장된 영상이 없습니다.", style: TextStyle(color: Colors.black)));
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
            
            // ★ 정렬: 최신순 (타임스탬프 큰 게 위로)
            items.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

            if (items.isEmpty) {
              return const Center(child: Text("저장된 영상이 없습니다.", style: TextStyle(color: Colors.grey)));
            }

            // ★ [핵심 변경] ListView -> GridView로 변경
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              // 한 줄에 3개 (crossAxisCount: 3)
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, 
                crossAxisSpacing: 10, // 가로 간격
                mainAxisSpacing: 10,  // 세로 간격
                childAspectRatio: 0.8, // 세로로 약간 긴 비율
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final data = items[index];
                final url = data['url'] ?? '';
                final ts = data['timestamp'];
                final filename = data['path'] ?? '파일';

                return InkWell(
                  onTap: () {
                    if (url.isNotEmpty) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(url: url, filename: filename)));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // 카드 배경색
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1. 영상 아이콘 (썸네일 대용)
                        const Icon(Icons.play_circle_fill, size: 40, color: Colors.black87),
                        const SizedBox(height: 10),
                        
                        // 2. 날짜 시간 표시
                        Text(
                          formatTs(ts),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}

// PlayerScreen은 변경 없음 (그대로 유지)
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
        _cc = ChewieController(
            videoPlayerController: _vc,
            autoPlay: true,
            looping: false,
            aspectRatio: _vc.value.aspectRatio);
      });
    } catch (e) {
      print("Error: $e");
    }
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
      appBar: AppBar(
          title: Text(widget.filename),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white),
      body: Center(
        child: _cc != null && _vc.value.isInitialized
            ? Chewie(controller: _cc!)
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}