import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as math;

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

class RecordButtonState extends State<RecordButton> with TickerProviderStateMixin {
  bool _isRecording;
  AnimationController _scaleController;
  Animation<double> _scaleAnimation;
  Animation<double> _iconOpacity;
  Animation<double> _arcAnimation;
  AnimationController _arcController;
  int _scaleDuration = 800;

  double get _bigCircleSize => 90.0;
  double get _smallCircleSize => 60.0;

  @override
  void initState() {
    super.initState();
    _isRecording = false;
    _initScaleAnimation();
    _initArcAnimation();
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
    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _arcController.forward();
      }
    });
  }

  void _initArcAnimation() {
    _arcController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5)
    );
    _arcAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_arcController)
    ..addListener((){
      setState((){});
    });

    _arcController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _arcController.reset();
        _stopRecording();
      }
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
      margin: EdgeInsets.all(4.0),
      height: _bigCircleSize,
      width: _bigCircleSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white24
      ),
      child: InkWell(
        customBorder: CircleBorder(),
        highlightColor: Colors.red,
        splashColor: Colors.red,
        child: CustomPaint(
          painter: ProgressPainter(
            color: Colors.green,
            value: _arcAnimation.value
          ),
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
    _arcController.stop();
    _arcController.reset();
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

class ProgressPainter extends CustomPainter {
  ProgressPainter({
    this.value,
    this.color,
  });

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..shader = LinearGradient(
          colors: [Colors.red, Colors.green, Colors.greenAccent]
        ).createShader(Rect.fromCircle(
          center: Offset(size.width/2, size.height/2),
          radius: size.width/2
        )
      );

    double progress = value * 360;
    canvas.drawArc(Offset.zero & size, math.radians(-90), math.radians(progress), true, paint);
  }

  @override
  bool shouldRepaint(ProgressPainter old) {
    return value != old.value || color != old.color;
  }
}