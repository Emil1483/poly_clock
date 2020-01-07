import 'dart:math' as math;
import 'package:fast_noise/fast_noise.dart' as noise;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class Point {
  static const double noiseSpeed = 0.1;
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
    pos = Vector2(noiseOff * width * 2 / 5 + center.x, center.y);

    zNoise += noiseSpeed * noiseSpeed;
  }

  void paint(Canvas canvas) {
    canvas.drawCircle(
      Offset(pos.x, pos.y),
      1.2,
      Paint()..color = Color(0xFFFFFFFF),
    );
  }
}

class Wallpaper {
  List<List<Point>> points = [];

  Wallpaper(Size size) {
    final int cols = 10;
    final int rows = 10;
    final double xOff = size.width / (rows * 2);
    final double yOff = size.height / (cols * 2);
    for (int i = 0; i < rows; i++) {
      List<Point> row = [];
      for (int j = 0; j < cols; j++) {
        row.add(
          Point(
            center: Vector2(
              j * size.width / rows + xOff,
              i * size.height / cols + yOff,
            ),
            width: size.width / rows,
          ),
        );
      }
      points.add(row);
    }
  }

  void update() {
    for (List<Point> ps in points) {
      for (Point p in ps) {
        p.update();
      }
    }
  }

  void paint(Canvas canvas) {
    for (List<Point> ps in points) {
      for (Point p in ps) {
        p.paint(canvas);
      }
    }
    for (List<Point> ps in points) {
      for (int i = 0; i < ps.length - 1; i++) {
        final Point p = ps[i];
        final Point other = ps[i + 1];
        final double distSq = p.pos.distanceToSquared(other.pos);
        canvas.drawLine(
          Offset(p.pos.x, p.pos.y),
          Offset(other.pos.x, other.pos.y),
          Paint()
            ..color = Color(0xFFFFFFFF).withAlpha((25000 / distSq).round())
            ..strokeWidth = 1000 / distSq,
        );
      }
    }
  }
}
