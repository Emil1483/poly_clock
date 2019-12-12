import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:vector_math/vector_math.dart';
import 'package:image/image.dart' as img;

import './boid.dart';
import './quad_tree.dart';

class SpriteWidgetRoot extends NodeWithSize {
  //TODO: make it fancy with triangles
  //TODO: add notice for apache licence https://www.apache.org/licenses/LICENSE-2.0

  DateTime dateTime = DateTime.now();
  ClockModel clockModel;

  List<Boid> boids = List<Boid>();

  static const int boidsPerChar = 80;

  QuadTree qTree;

  SpriteWidgetRoot({ClockModel model}) : super(const Size(500, 300)) {
    clockModel = model;
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

  void addFromChar(int index, String char, {bool update = false}) {
    final double padding = 25;
    final double width = size.width / 8;
    final double height = size.height * 0.55;
    final double between = 45;
    img.Image text = img.drawChar(img.Image(21, 35), img.arial_48, 0, 0, char);
    img.Image photo = img.copyResize(text, height: 400, width: -1);
    addFromImage(
      photo,
      width: width,
      height: height,
      boidIndex: update ? index : null,
      xOff: index * width +
          (index >= 2 ? size.width - width * 4 : 0) +
          (index >= 2 ? -padding : padding) +
          (index == 1 ? between : 0) +
          (index == 2 ? -between : 0),
    );
  }

  String charAt(int number, int index) {
    String numString = (number < 10 ? "0" : "") + number.toString();
    return numString.substring(index, index + 1);
  }

  void setTime(DateTime time) {
    if (boids.length == 0) {
      addFromChar(0, charAt(time.hour, 0));
      addFromChar(1, charAt(time.hour, 1));
      addFromChar(2, charAt(time.minute, 0));
      addFromChar(3, charAt(time.minute, 1));
      return;
    }

    addFromChar(3, charAt(time.minute, 1), update: true);

    if (charAt(time.minute, 0) != charAt(dateTime.minute, 0))
      addFromChar(2, charAt(time.minute, 0), update: true);

    if (charAt(time.hour, 1) != charAt(dateTime.hour, 1))
      addFromChar(1, charAt(time.hour, 1), update: true);

    if (charAt(time.hour, 0) != charAt(dateTime.hour, 0))
      addFromChar(0, charAt(time.hour, 0), update: true);

    dateTime = time;
  }

  void updateModel(ClockModel model) => clockModel = model;

  @override
  void update(_) {
    print(1/_);
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
      List<Boid> others = queryBoids(boid.pos);
      boid.flock([]);
      boid.update();
    }
  }

  List<Boid> queryBoids(Vector2 pos) {
    if (qTree == null) return [];
    List<Point> data = qTree.circleQuery(pos, Boid.observeRadius);
    return data.map((Point p) => p.data as Boid).toList();
  }

  @override
  void paint(Canvas canvas) {
    for (Boid boid in boids) {
      //List<Boid> others = queryBoids(boid.pos);
      boid.paint(canvas, []);
    }
  }
}
