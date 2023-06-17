import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class ShowImageScreen extends StatelessWidget {
  final String uri;
  final bool isWantDownload;

  const ShowImageScreen({super.key, required this.uri, required this.isWantDownload});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: !isWantDownload
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {},
                  ),
                ),
              ),
        body: GestureDetector(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white70,
            child: Center(
              child: Hero(
                tag: uri,
                child: Image.network(
                  uri,
                  fit: BoxFit.fill,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Image.asset(
                      "images/no_network.jpg",
                    );
                  },
                ),
              ),
            ),
          ),
          // onPanDown: (s){
          //   Navigator.pop(context);
          // },
          onPanEnd: (end) {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

///////////////////////////////

class ShowVideoScreen extends StatefulWidget {
  final String? videoUrl;
  final String? videoPath;

  const ShowVideoScreen({Key? key, required this.videoUrl, required this.videoPath}) : super(key: key);

  @override
  State<ShowVideoScreen> createState() => _ShowVideoScreenState();
}

class _ShowVideoScreenState extends State<ShowVideoScreen> {
  late VideoPlayerController _controller;

  bool isGettingVideo = false;

  @override
  void initState() {
    super.initState();
    isGettingVideo = true;
    _controller = widget.videoPath != null
        ? VideoPlayerController.file(File(widget.videoPath!))
        : VideoPlayerController.network(widget.videoUrl!)
      ..initialize().then((_) {
        _controller.play();
        isGettingVideo = false;
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video"),
      ),
      body: isGettingVideo
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

