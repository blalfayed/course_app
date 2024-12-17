// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class FetchVideoPage extends StatefulWidget {
  static String screenRoute = 'fetch_video_page';

  final String courseId; // معرف الدورة لجلب الفيديو الخاص بها

  const FetchVideoPage({required this.courseId, super.key});

  @override
  _FetchVideoPageState createState() => _FetchVideoPageState();
}

class _FetchVideoPageState extends State<FetchVideoPage> {
  late Future<String?> _videoUrlFuture;
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoUrlFuture = _fetchVideoUrl(widget.courseId);
  }

  Future<String?> _fetchVideoUrl(String courseId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();

      if (doc.exists) {
        return doc['videos'] as String?; // جلب رابط الفيديو
      } else {
        debugPrint("Document does not exist");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching video URL: $e");
      return null;
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    try {
      _videoController = VideoPlayerController.network(videoUrl)
        ..addListener(() {
          if (mounted) {
            setState(() {});
          }
        })
        ..setLooping(true);

      await _videoController!.initialize();
      setState(() {
        _isInitialized = true;
      });
      _videoController!.play(); // تشغيل الفيديو تلقائيًا
    } catch (e) {
      debugPrint("Error initializing video player: $e");
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Video"),
      ),
      body: FutureBuilder<String?>(
        future: _videoUrlFuture, // استدعاء الدالة لجلب الفيديو
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // عرض مؤشر تحميل
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"), // عرض رسالة خطأ
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
                    "No video URL found for this course.")); // عرض رسالة إذا لم يتم العثور على الفيديو
          } else {
            if (!_isInitialized && _videoController == null) {
              _initializeVideoPlayer(snapshot.data!);
            }

            return Center(
              child: _isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const CircularProgressIndicator(), // عرض مؤشر التحميل أثناء التهيئة
            );
          }
        },
      ),
      floatingActionButton: _isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
              child: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            )
          : null, // إخفاء الزر إذا لم يتم التهيئة
    );
  }
}
