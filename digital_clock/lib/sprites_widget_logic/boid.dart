import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class Boid {
  static const double observeRadius = 50;
  static const double observeRadiusSq = observeRadius * observeRadius;

  static const double alignmentForce = 1;
  static const double alignmentSpeed = 70;

  static const double padding = 5;

  Size canvasSize;
  Vector2 pos;
  Vector2 vel;

  Boid(Size size) {
    canvasSize = size;

    pos = Vector2.random();
    pos.x *= canvasSize.width;
    pos.y *= canvasSize.height;

    final r = math.Random();
    vel = Vector2(
      r.nextDouble() - 0.5,
      r.nextDouble() - 0.5,
    );
    vel.scale(50);
  }

  void edges() {
    if (pos.x < -padding) pos.x = canvasSize.width + padding;
    if (pos.x > canvasSize.width + padding) pos.x = -padding;
    if (pos.y < -padding) pos.y = canvasSize.height + padding;
    if (pos.y > canvasSize.height + padding) pos.y = -padding;
  }

  void flock(List<Boid> boids) {
    int total = 0;
    Vector2 steering = Vector2.zero();
    for (Boid other in boids) {
      if (pos.distanceToSquared(other.pos) > observeRadiusSq) continue;
      steering.add(other.vel);
      total++;
    }
    //steering.scale(1/total);
    steering.normalize();
    steering.scale(alignmentSpeed);
    steering.sub(vel);
    if (steering.length > alignmentForce) {
      steering.normalize();
      steering.scale(alignmentForce);
    }
    applyForce(steering);
  }

  void applyForce(Vector2 force) {
    vel.add(force);
  }

  void update(double dt) {
    edges();
    pos.add(vel * dt);
  }

  void paint(Canvas canvas) {
    canvas.drawCircle(
        Offset(pos.x, pos.y), padding, Paint()..color = Color(0xFF000000));
  }
}
