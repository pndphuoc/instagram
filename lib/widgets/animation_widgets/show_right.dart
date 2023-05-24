import 'dart:async';
import 'package:flutter/material.dart';

class ShowRight extends StatefulWidget {
  final Widget child;
  final int delay;

  const ShowRight({Key? key, required this.child, this.delay = 0}) : super(key: key);

  @override
  State<ShowRight> createState() => _ShowRightState();
}

class _ShowRightState extends State<ShowRight> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    final curve =
    CurvedAnimation(curve: Curves.decelerate, parent: _animController);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.35, 0.0), end: Offset.zero)
            .animate(curve);

    if (widget.delay == 0) {
      _animController.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay), () {
        _animController.forward();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animController.stop();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animController,
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
    );
  }
}