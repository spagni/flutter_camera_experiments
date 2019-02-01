import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'timer.dart';
import 'package:video_player/video_player.dart';
import 'record_button.dart';

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
        backgroundColor: Colors.black54,
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

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller)
            ),
          ),
          _buildGradient(),
          _buildButtonBar()
        ],
      ),
    );
  }

  Widget _buildButtonBar() {
    return Positioned(
      bottom: 6.0,
      left: 0.0,
      right: 0.0,
      child: RecordButton(
        onStart: _filmVideo,
        onEnd: _stop,
      )
      // Row(
      //   children: <Widget>[
      //     Expanded(
      //       child: (_controller.value.isRecordingVideo) 
      //       ? Timer(
      //           onFinish: _stop,
      //         )
      //       : SizedBox()
      //     ),
      //     Expanded(
      //       child: (_controller.value.isRecordingVideo) 
      //         ? _buildButton(_stop, Icon(Icons.stop, color: Colors.red, size : 90))
      //         : RecordButton(
      //           onPressed: _filmVideo,
      //         )
      //     ),
      //     Expanded(
      //       child: _buildButton(_playLast, Icon(Icons.play_arrow, color: Colors.white54, size : 90))
      //     ),
      //   ],
      // ),
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
      
      _videoPath = '$_appDir/video${Random().nextInt(1000)}.mp4';
      
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

  Widget _buildGradient() {
    //Sirve para cuando la camara se superpone con buttonBar
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black54],
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          stops: [0.4, 1.0]

        )
      ),
    );
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