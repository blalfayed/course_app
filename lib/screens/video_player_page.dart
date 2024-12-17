// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoPlayerPage extends StatefulWidget {
  static String screenRoute = 'video_player_page';

  final String courseId;

  const VideoPlayerPage({required this.courseId, super.key});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  List<YoutubePlayerController> _youtubeControllers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndInitializeVideos();
  }

  Future<void> _fetchAndInitializeVideos() async {
    try {
      final videoUrls = await _fetchVideoUrls(widget.courseId);

      if (videoUrls != null && videoUrls.isNotEmpty) {
        _youtubeControllers = videoUrls.map((videoUrl) {
          final videoId = YoutubePlayer.convertUrlToId(videoUrl);
          if (videoId != null) {
            return YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
              ),
            );
          } else {
            throw Exception("Invalid YouTube URL.");
          }
        }).toList();

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching or initializing videos: $e");
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Failed to load videos. Please try again later.");
    }
  }

  Future<List<String>?> _fetchVideoUrls(String courseId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();

      if (doc.exists) {
        return List<String>.from(
            doc['videos'] ?? []); // جلب قائمة روابط الفيديوهات
      } else {
        debugPrint("Document does not exist");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching video URLs: $e");
      return null;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _youtubeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'YouTube Videos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _youtubeControllers.isEmpty
                ? const Center(
                    child: Text(
                      "No videos found for this course.",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: _youtubeControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        child: YoutubePlayer(
                          controller: _youtubeControllers[index],
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.teal,
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
