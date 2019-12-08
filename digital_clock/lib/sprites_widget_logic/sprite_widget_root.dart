import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:vector_math/vector_math.dart';

import './boid.dart';
import './quad_tree.dart';

class SpriteWidgetRoot extends NodeWithSize {
  //TODO: implement quadTree https://youtu.be/OJxEcs0w_kE
  //TODO: add steering toward part of number
  //TODO: make it fancy with triangles

  DateTime dateTime = DateTime.now();
  ClockModel clockModel;

  List<Boid> boids = List<Boid>();

  QuadTree qTree;

  SpriteWidgetRoot({ClockModel model}) : super(const Size(500, 300)) {
    clockModel = model;
    for (int i = 0; i < 500; i++) {
      boids.add(Boid(size));
    }
  }

  void setTime(DateTime time) => dateTime = time;

  void updateModel(ClockModel model) => clockModel = model;

  @override
  void update(double dt) {
    qTree = QuadTree(
      pos: Vector2(size.width / 2, size.height / 2),
      w: size.width,
      h: size.height,
    );

    for (Boid boid in boids) {
      qTree.insert(
        Point(pos: boid.pos, data: boid),
      );
    }
    for (Boid boid in boids) {
      boid.flock(boids);
      boid.update(dt);
    }
  }

  @override
  void paint(Canvas canvas) {
    for (Boid boid in boids) {
      boid.paint(canvas);
    }
    if (qTree == null) return;
    qTree.paint(canvas);
    canvas.drawCircle(
      Offset(100, 100),
      50,
      Paint()
        ..color = Color(0xFF00FF00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    List<Point> found = qTree.circleQuery(Vector2(100, 100), 50);
    for (Point p in found) {
      canvas.drawCircle(
        Offset(p.pos.x, p.pos.y),
        5,
        Paint()..color = Color(0xFF00FF00),
      );
    }
  }

/*
    List<Point> found = qTree.query(Vector2(114, 220), 200, 100);
    for (Point p in found) {
      canvas.drawCircle(
        Offset(p.pos.x, p.pos.y),
        10,
        Paint()..color = Color(0xFF0000FF),
      );
    }
  }
  */
}
