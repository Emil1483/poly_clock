import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:vector_math/vector_math.dart';
import 'package:image/image.dart' as img;

import './boid.dart';
import './quad_tree.dart';

class SpriteWidgetRoot extends NodeWithSize {
  //TODO: add steering toward part of number. Use https://pub.dev/packages/image#-readme-tab-
  //TODO: make it fancy with triangles
  //TODO: add notice for apache licence https://www.apache.org/licenses/LICENSE-2.0

  DateTime dateTime = DateTime.now();
  ClockModel clockModel;

  List<Boid> boids = List<Boid>();

  QuadTree qTree;

  SpriteWidgetRoot({ClockModel model}) : super(const Size(500, 300)) {
    clockModel = model;
    addBoids();
  }

  void addBoids() async {
    Color pixel32ToColor(int argbColor) {
      int r = (argbColor >> 16) & 0xFF;
      int b = argbColor & 0xFF;
      return Color((argbColor & 0xFF00FF00) | (b << 16) | r);
    }

    ByteData imageBytes = await rootBundle.load("digital_dark.png");
    List<int> values = imageBytes.buffer.asUint8List();
    img.Image photo = img.decodeImage(values);
    List<Color> pixels = photo.data.map(pixel32ToColor).toList();

    List<Vector2> goodSpots = [];
    for (int i = 0; i < photo.width; i++) {
      for (int j = 0; j < photo.height; j++) {
        int index = i + j * photo.width;
        if (pixels[index] == Color(0xffffffff)) {
          double x = i * size.width / photo.width;
          double y = j * size.height / photo.height;
          goodSpots.add(Vector2(x, y));
        }
      }
    }

    for (int i = 0; i < 500; i++) {
      int index = math.Random().nextInt(goodSpots.length);
      boids.add(Boid(size, goodSpots[index]));
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
