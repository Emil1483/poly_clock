import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:spritewidget/spritewidget.dart';

class SpriteWidgetRoot extends NodeWithSize {
  DateTime _dateTime = DateTime.now();
  ClockModel _clockModel;

  SpriteWidgetRoot({ClockModel clockModel}) : super(const Size(500, 300)) {
    _clockModel = clockModel;
  }

  double x = 0;

  void setTime(DateTime time) => _dateTime = time;

  void updateModel(ClockModel model) => _clockModel = model;

  @override
  void update(double dt) {
    x += dt * 50;
  }

  @override
  void paint(Canvas canvas) {
    super.paint(canvas);
    canvas.drawCircle(Offset(x, 100), 10, Paint()..color = Colors.red);
  }
}
