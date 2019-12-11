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

  static const int boidsPerChar = 100;

  QuadTree qTree;

  SpriteWidgetRoot({ClockModel model}) : super(const Size(500, 300)) {
    clockModel = model;
    addBoids();
  }

  void addBoids() {
    addFromChar("0", 0);
    addFromChar("2", 1);
    addFromChar("4", 2);
    addFromChar("0", 3);
  }

  void addFromImage(
    img.Image image, {
    @required double width,
    @required double height,
    @required double xOff,
    int boidIndex,
  }) {
    Color pixel32ToColor(int argbColor) {
      int r = (argbColor >> 16) & 0xFF;
      int b = argbColor & 0xFF;
      return Color((argbColor & 0xFF00FF00) | (b << 16) | r);
    }

    List<Color> pixels = image.data.map(pixel32ToColor).toList();
    List<Vector2> goodSpots = [];
    for (int i = 0; i < image.width; i++) {
      for (int j = 0; j < image.height; j++) {
        int index = i + j * image.width;
        if (pixels[index] == Color(0xffffffff)) {
          double x = i * width / image.width + xOff;
          double y = j * height / image.height + (size.height - height) / 2;
          goodSpots.add(Vector2(x, y));
        }
      }
    }

    if (boidIndex == null) {
      for (int i = 0; i < boidsPerChar; i++) {
        int index = math.Random().nextInt(goodSpots.length);
        boids.add(Boid(size, goodSpots[index]));
      }
    } else {
      for (int i = 0; i < boidsPerChar; i++) {
        int index = math.Random().nextInt(goodSpots.length);
        int boid = boidIndex * boidsPerChar + i;
        boids[boid].setTarget(goodSpots[index]);
      }
    }
  }

  void addFromChar(String char, int index) {
    final double padding = 25;
    final double width = size.width / 6.5;
    final double height = size.height * 0.65;
    final double between = 25;
    img.Image text = img.drawChar(img.Image(21, 35), img.arial_48, 0, 0, char);
    img.Image photo = img.copyResize(text, height: 400, width: -1);
    addFromImage(
      photo,
      width: width,
      height: height,
      xOff: index * width +
          (index >= 2 ? size.width - width * 4 : 0) +
          (index >= 2 ? -padding : padding) +
          (index == 1 ? between : 0) +
          (index == 2 ? -between : 0),
    );
  }

  void updateChar(int index, String char) {}

  void setTime(DateTime time) {
    dateTime = time;
    print(time);
  }

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
