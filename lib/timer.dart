import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  final VoidCallback onFinish;

  Timer({ @required this.onFinish })
    : assert(onFinish != null);
  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<int> _animation;
  int _duration;

  @override
  void initState() {
    super.initState();

    _duration = 5;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _duration)
    );
    _animation = StepTween(begin: 0, end: _duration).animate(_controller)
      ..addListener((){
        setState((){});
      });

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onFinish();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          '${_animation.value}/$_duration',
          style: TextStyle(
            fontSize: 50.0
          ),
        ),
      )
    );
  }
}