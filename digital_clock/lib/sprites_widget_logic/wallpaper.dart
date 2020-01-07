import 'dart:math' as math;
import 'package:fast_noise/fast_noise.dart' as noise;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class Point {
  static const double noiseSpeed = 0.05;
  static const double noiseDiff = 1;

  final SimplexNoise noise = SimplexNoise();
  final double width;
  final Vector2 center;

  Vector2 pos;
  double zNoise = 0;

  Point({
    @required this.center,
    @required this.width,
  }) {
    pos = Vector2.copy(center);
  }

  void update() {
    final double noiseOff =
        noise.noise3D(center.x * noiseDiff, center.y * noiseDiff, zNoise);
    pos = Vector2(noiseOff * width / 2 + center.x, center.y);

    zNoise += noiseSpeed * noiseSpeed;
  }

  void paint(Canvas canvas) {
    canvas.drawCircle(
      Offset(pos.x, pos.y),
      2,
      Paint()..color = Color(0xFFFFFFFF),
    );
  }
}

class Wallpaper {
  List<Point> points = [];

  Wallpaper(Size size) {
    final int cols = 10;
    final int rows = 10;
    final double xOff = size.width / (rows * 2);
    final double yOff = size.height / (cols * 2);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        points.add(
          Point(
            center: Vector2(
              i * size.width / rows + xOff,
              j * size.height / cols + yOff,
            ),
            width: size.width / rows,
          ),
        );
      }
    }
  }

  void update() {
    for (Point p in points) {
      p.update();
    }
  }

  void paint(Canvas canvas) {
    for (Point p in points) {
      p.paint(canvas);
    }
  }
}
