import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class Point {
  static const double noiseSpeed = 0.07;
  static const double noiseDiff = 0.1;

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
    pos = Vector2(noiseOff * width * 3 / 4 + center.x, center.y);

    zNoise += noiseSpeed * noiseSpeed;
  }

  void paint(Canvas canvas) {
    canvas.drawCircle(
      Offset(pos.x, pos.y),
      1.3,
      Paint()..color = Color(0xFFFFFFFF),
    );
  }
}

class Wallpaper {
  final Size size;

  List<List<Point>> points = [];
  Brightness theme;

  Wallpaper(this.size) {
    final int cols = 6;
    final int rows = 6;
    final double xOff = size.width / (cols * 2);
    final double yOff = size.height / (rows * 2);
    for (int i = 0; i < rows; i++) {
      List<Point> row = [];
      for (int j = 0; j < cols; j++) {
        row.add(
          Point(
            center: Vector2(
              j * size.width / cols + xOff,
              i * size.height / rows + yOff,
            ),
            width: size.width / cols,
          ),
        );
      }
      points.add(row);
    }
  }

  void updateTheme(Brightness brightness) {
    theme = brightness;
  }

  void update() {
    for (List<Point> ps in points) {
      for (Point p in ps) {
        p.update();
      }
    }
  }

  List<Color> getShaderColors() {
    if (theme == Brightness.dark) {
      return [Color(0xFF29323D), Color(0xFF111111)];
    } else {
      return [Color(0xFF73D863), Color(0xFF5DAD4F)];
    }
  }

  void paint(Canvas canvas) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: getShaderColors(),
          transform: GradientRotation(math.pi / 2),
        ).createShader(rect),
    );

    for (List<Point> ps in points) {
      for (Point p in ps) {
        p.paint(canvas);
      }
    }
    for (List<Point> row in points) {
      for (int i = 0; i < row.length - 1; i++) {
        final Point p = row[i];
        final Point other = row[i + 1];
        final double dist = (p.pos.x - other.pos.x).abs();
        final double strenght = (50 / dist - 0.5).clamp(0.01, 1.0);
        if (dist == 0) continue;
        canvas.drawLine(
          Offset(p.pos.x, p.pos.y),
          Offset(other.pos.x, other.pos.y),
          Paint()
            ..color =
                Color(0xFFFFFF).withAlpha((strenght * 255).round())
            ..strokeWidth = strenght * 4.5
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }
}
