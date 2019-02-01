import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'timer.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(CameraApp());


class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primaryColor: Colors.amber
      ),
      home: Scaffold(
        body: CameraWidget()
      ),
    );
  }
}

class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  List<CameraDescription> _cameras;
  CameraController _controller;
  String _appDir;
  String _videoPath;

  @override
  void initState() {
    super.initState();
    _loadCamera();
  }

  void _loadCamera() async {
    _appDir = (await getApplicationDocumentsDirectory()).path;
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
    void dispose() {
      super.dispose();
      _controller.dispose();
    }
  @override
  Widget build(BuildContext context) {
    if (_controller == null || 
    (_controller.value != null && !_controller.value.isInitialized)) 
      return Center(child: CircularProgressIndicator());

    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: CameraPreview(_controller)
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: (_controller.value.isRecordingVideo) 
              ? Timer(
                  onFinish: _stop,
                )
              : SizedBox()
            ),
            Expanded(
              child: (_controller.value.isRecordingVideo) 
                ? _buildButton(_stop, Icon(Icons.stop, color: Colors.red, size : 90))
                : _buildButton(_filmVideo, Icon(Icons.videocam, color: Colors.red, size : 90)),
            ),
            Expanded(
              child: _buildButton(_playLast, Icon(Icons.play_arrow, color: Colors.black38, size : 90))
            ),
          ],
        )
      ],
    );
  }

  Widget _buildButton(VoidCallback onTap, Icon icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: StadiumBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: icon
        ),
        onTap: onTap,
      )
    );
  }

  void _takePicture() async {
    try {
      await _controller.takePicture('$_appDir/image.jpg');
      print('Picture taken in $_appDir/image.jpg');
    } 
    catch(e) {
      print(e.toString());
    }
  }

  void _filmVideo() async {
    try {
      if (_controller.value.isRecordingVideo) return;
      
      _videoPath = '$_appDir/video${Random().nextInt(10000)}.mp4';
      
      await _controller.startVideoRecording(_videoPath);
      setState((){});
      print('Video taken in $_videoPath');
    } 
    catch(e) {
      print(e.toString());
    }
  }

  void _stop() async {
    try {
      await _controller.stopVideoRecording();
      setState((){});
      print('VIDEO STOPPED');
    }
    catch(e){
      print(e.toString());
    }
  }

  void _playLast() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Video(
        file: File(_videoPath)
      )
    ));
  }
}

class Video extends StatefulWidget {
  final File file;

  Video({ @required this.file });
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.file);
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      setState((){});
      _controller.play();
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video')),
      body: VideoPlayer(
        _controller
      ),
    );
  }
}