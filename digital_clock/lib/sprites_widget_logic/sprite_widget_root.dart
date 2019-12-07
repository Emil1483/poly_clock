import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:spritewidget/spritewidget.dart';

import './boid.dart';

class SpriteWidgetRoot extends NodeWithSize {
  DateTime _dateTime = DateTime.now();
  ClockModel _clockModel;

  List<Boid> _boids = List<Boid>();

  SpriteWidgetRoot({ClockModel clockModel}) : super(const Size(500, 300)) {
    _clockModel = clockModel;
    for (int i = 0; i < 100; i++) {
      _boids.add(Boid(size));
    }
  }

  void setTime(DateTime time) => _dateTime = time;

  void updateModel(ClockModel model) => _clockModel = model;

  @override
  void update(double dt) {
    for (Boid boid in _boids) {
      boid.flock(_boids);
      boid.update(dt);
    }
  }

  @override
  void paint(Canvas canvas) {
    for (Boid boid in _boids) {
      boid.paint(canvas);
    }
  }
}
