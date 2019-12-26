import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

abstract class Particle {
  static const double padding = 100;

  Vector2 pos;
  final double z;
  final Size size;

  Particle({
    @required this.size,
    @required this.z,
  }) {
    math.Random r = math.Random();
    pos = Vector2(
      r.nextDouble() * (size.width),
      r.nextDouble() * (size.height + padding * 2) - padding,
    );
  }

  void update();

  void edges() {
    if (pos.y > size.height + padding) {
      pos.y = -padding;
      pos.x = math.Random().nextDouble() * (size.width);
    }
    if (pos.x > size.width + padding) pos.x = -padding;
    if (pos.x < -padding) pos.x = size.width + padding;
  }

  void paint(Canvas canvas);

  String toString() {
    return "pos: $pos";
  }
}

class Rain extends Particle {
  static const double rainLen = 1.5;
  static const double speed = 25;

  Rain({
    @required Size size,
    @required double z,
  }) : super(size: size, z: z);

  @override
  void update() {
    pos.y += speed / (z * z);
    super.edges();
  }

  @override
  void paint(Canvas canvas) {
    canvas.drawLine(
      Offset(pos.x, pos.y),
      Offset(
        pos.x,
        pos.y - speed * rainLen / (z * z),
      ),
      Paint()
        ..color = HSLColor.fromAHSL(1, -(z - 1) * 30 + 215, 1, 0.5).toColor()
        ..strokeWidth = 0.5 / (z * z),
    );
  }
}

class Snow extends Particle {
  double t = math.Random().nextDouble() * math.pi * 2;

  Snow({
    @required Size size,
    @required double z,
  }) : super(size: size, z: z);

  @override
  void update() {
    pos.y += 0.5 / (z * z);
    
    t += 0.025;
    pos.x += math.sin(t) / (2 * z * z);

    super.edges();
  }

  @override
  void paint(Canvas canvas) {
    canvas.drawCircle(
      Offset(pos.x, pos.y),
      2 / (z * z),
      Paint()..color = Color(0xFFFFFFFF),
    );
  }
}

class Effects {
  final List<Particle> particles = List<Particle>();
  final Size size;

  Effects(this.size) {
    final int max = 350;
    for (int i = 0; i < max; i++) {
      particles.add(
        Snow(size: size, z: (i * i) * 0.75 / (max * max) + 1),
      );
    }
  }

  void update() {
    for (Particle p in particles) {
      p.update();
    }
  }

  void paint(Canvas canvas) {
    for (Particle p in particles) {
      p.paint(canvas);
    }
  }
}
