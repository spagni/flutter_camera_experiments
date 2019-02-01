import 'package:flutter/material.dart';

class RecordButton extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onEnd;

  RecordButton({ @required this.onStart, @required this.onEnd })
    : assert(onStart != null),
      assert(onEnd != null);

  @override
  RecordButtonState createState() {
    return new RecordButtonState();
  }
}

class RecordButtonState extends State<RecordButton> with SingleTickerProviderStateMixin {
  bool _isRecording;
  AnimationController _scaleController;
  Animation<double> _scaleAnimation;
  Animation<double> _iconOpacity;
  int _scaleDuration = 1000;

  double get _bigCircleSize => 100.0;
  double get _smallCircleSize => 60.0;

  @override
  void initState() {
    super.initState();
    _isRecording = false;
    _initScaleAnimation();
  }

  void _initScaleAnimation() {
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _scaleDuration)
    );

    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Interval(0.3, 1.0),
      parent: _scaleController
    ))
    ..addListener(()=> setState((){}));

    _scaleAnimation = Tween<double>(begin: _smallCircleSize, end: _bigCircleSize).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.fastOutSlowIn
      )
    )..addListener((){
      setState((){});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scaleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _bigCircleSize,
      width: _bigCircleSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white12
      ),
      child: InkWell(
        customBorder: CircleBorder(),
        highlightColor: Colors.red,
        splashColor: Colors.red,
        child: Container(
          height: _scaleAnimation.value,
          width: _scaleAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white
          ),
          alignment: Alignment.center,
          child: _stopIcon()
        ),
        onTap: (_isRecording) ? _stopRecording : _startRecording 
      )
    );
  }

  void _startRecording() {
    // widget.onStart();
    setState(() {
      _isRecording = true;
    });
    _scaleController.forward();
  }

  void _stopRecording() {
    // widget.onEnd();
    _scaleController.reverse();
    setState(() {
      _isRecording = false;
    });
  }

  Widget _stopIcon() {
    return Opacity(
      opacity: _iconOpacity.value,
      child: Icon(Icons.stop, color: Colors.red, size: 70.0)
    );
  }
}