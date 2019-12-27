import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';
import 'package:image/image.dart' as img;

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
  final ui.Image image;
  final Rect src;

  double t = math.Random().nextDouble() * math.pi * 2;

  Snow({
    @required Size size,
    @required double z,
    @required this.image,
    @required this.src,
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
    final double size = 8 / (z * z);
    canvas.save();
    canvas.translate(pos.x, pos.y);
    canvas.rotate(math.sin(t));
    canvas.drawImageRect(
      image,
      src,
      Rect.fromCenter(center: Offset.zero, width: size, height: size),
      Paint(),
    );
    canvas.restore();
  }
}

class Effects {
  final List<Particle> particles = List<Particle>();
  final Size size;

  Effects(this.size) {
    addSnow();
  }

  void addSnow() async {
    ByteData imageBytes = await rootBundle.load("assets/snow.png");
    List<int> values = imageBytes.buffer.asUint8List();
    ui.Image image = await decodeImageFromList(values);
    math.Random r = math.Random();
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < i * i * 40; j++) {
        particles.add(
          Snow(
            size: size,
            z: i * 0.35 + 0.65,
            image: image,
            src: Rect.fromLTWH(
              r.nextInt(3).toDouble() * 51,
              r.nextInt(3).toDouble() * 51,
              50,
              50,
            ),
          ),
        );
      }
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
