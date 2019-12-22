import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class Boid {
  static const double observeRadius = 16;
  static const double observeRadiusSq = observeRadius * observeRadius;

  static const double speed = 2.2;

  static const double alignmentForce = 0.18;
  static const double cohesionForce = 0.14;
  static const double separationForce = 0.16;
  static const double locateForce = 0.22;

  static const double padding = 2;

  static const double closeThreshMax = 100;
  static const double closeThreshMin = 50;
  static const double comingMult = 0.06;

  double far = 0.0;

  Size canvasSize;
  Vector2 pos;
  Vector2 vel;
  Vector2 acc;

  Vector2 target;

  double colorConst;

  Boid(Size size, Vector2 t) {
    canvasSize = size;

    target = Vector2.copy(t);

    pos = Vector2.copy(t);

    vel = Vector2.zero();
    acc = Vector2.zero();

    colorConst = math.Random().nextDouble() * 2 - 1;
  }

  void steer({
    @required Vector2 Function() getDesired,
    @required double maxForce,
  }) {
    Vector2 desired = getDesired();
    desired.normalize();
    desired.scale(speed);
    Vector2 steering = desired - vel;
    if (steering.length > maxForce) {
      steering.normalize();
      steering.scale(maxForce);
    }
    applyForce(steering);
  }

  void edges() {
    if (pos.x > canvasSize.width + padding) pos.x = -padding;
    if (pos.x < -padding) pos.x = canvasSize.width + padding;
    if (pos.y > canvasSize.height + padding) pos.y = -padding;
    if (pos.y < -padding) pos.y = canvasSize.height + padding;
  }

  void alignment(List<Boid> boids) {
    steer(
      maxForce: alignmentForce * far,
      getDesired: () {
        Vector2 desired = Vector2.zero();
        int total = 0;
        for (Boid other in boids) {
          if (other == this) continue;
          desired.add(other.vel);
          total++;
        }
        if (total == 0) return Vector2.copy(vel);
        return desired;
      },
    );
  }

  void cohesion(List<Boid> boids) {
    steer(
      maxForce: cohesionForce * far,
      getDesired: () {
        Vector2 desired = Vector2.zero();
        int total = 0;
        for (Boid other in boids) {
          if (other == this) continue;
          desired.add(other.pos);
          total++;
        }
        if (total == 0) return Vector2.copy(vel);
        desired.scale(1 / total);
        desired.sub(pos);
        return desired;
      },
    );
  }

  void spearation(List<Boid> boids) {
    steer(
      maxForce: separationForce * far,
      getDesired: () {
        Vector2 desired = Vector2.zero();
        int total = 0;
        for (Boid other in boids) {
          if (other == this) continue;
          final dist = pos.distanceTo(other.pos);
          desired.add((pos - other.pos) / dist);
          total++;
        }
        if (total == 0) return Vector2.copy(vel);

        return desired;
      },
    );
  }

  void locate() {
    steer(
      maxForce: locateForce,
      getDesired: () => target - pos,
    );
  }

  void setTarget(Vector2 t) {
    target.setFrom(t);
  }

  void flock(List<Boid> boids) {
    alignment(boids);
    cohesion(boids);
    spearation(boids);
    locate();
  }

  void applyForce(Vector2 force) {
    acc.add(force);
  }

  void update() {
    far = ((pos.distanceToSquared(target) - closeThreshMin) /
            (closeThreshMax - closeThreshMin))
        .clamp(0.0, 1.0);
    if (far < 1) {
      final double close = 1 - far;
      Vector2 diff = target - pos;
      diff.scale(comingMult * close);
      pos.add(diff);
    }

    vel.add(acc);
    pos.add(vel * far);
    edges();

    colorConst += vel.length2 / 50;
    if (colorConst > 1) colorConst = -1;

    acc.setZero();
  }

  void paint(Canvas canvas) {
    //canvas.drawCircle(
    //  Offset(target.x, target.y),
    //  4,
    //  Paint()..color = Color(0xFFFFFF00),
    //);
    canvas.drawCircle(
      Offset(pos.x, pos.y),
      3,
      Paint()..color = Color(0xFFFFFFFF),
    );
    return;
    final textStyle = ui.TextStyle(
      color: Color(0xFF000000),
      fontSize: 30,
    );
    final paragraphStyle = ui.ParagraphStyle(
      textDirection: TextDirection.ltr,
    );
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText('$far');
    final constraints = ui.ParagraphConstraints(width: 300);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(constraints);
    final offset = Offset(pos.x, pos.y);
    canvas.drawParagraph(paragraph, offset);
  }
}
