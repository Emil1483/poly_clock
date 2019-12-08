import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:vector_math/vector_math.dart';

import './boid.dart';
import './quad_tree.dart';

class SpriteWidgetRoot extends NodeWithSize {
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
  void update(_) {
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
      List<Point> data = qTree.circleQuery(boid.pos, Boid.observeRadius);
      List<Boid> others = data.map((Point p) => p.data as Boid).toList();
      boid.flock(others);
      boid.update();
    }
  }

  @override
  void paint(Canvas canvas) {
    for (Boid boid in boids) {
      boid.paint(canvas);
    }
  }
}
