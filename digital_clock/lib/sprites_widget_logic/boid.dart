import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class Boid {
  static const double observeRadius = 26;
  static const double observeRadiusSq = observeRadius * observeRadius;

  static const double speed = 2.2;

  static const double alignmentForce = 0.18;
  static const double cohesionForce = 0.13;
  static const double separationForce = 0.18;
  static const double locateForce = 0.2;

  static const double padding = 2;

  Size canvasSize;
  Vector2 pos;
  Vector2 vel;
  Vector2 acc;

  Vector2 target;

  Boid(Size size, Vector2 t) {
    canvasSize = size;

    target = Vector2.copy(t);

    pos = Vector2.random();
    pos.x *= canvasSize.width;
    pos.y *= canvasSize.height;

    final r = math.Random();
    vel = Vector2(
      r.nextDouble() - 0.5,
      r.nextDouble() - 0.5,
    );
    acc = Vector2.zero();
  }

  void edges() {
    if (pos.x < -padding) pos.x = canvasSize.width + padding;
    if (pos.x > canvasSize.width + padding) pos.x = -padding;
    if (pos.y < -padding) pos.y = canvasSize.height + padding;
    if (pos.y > canvasSize.height + padding) pos.y = -padding;
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

  void alignment(List<Boid> boids) {
    steer(
      maxForce: alignmentForce,
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
      maxForce: cohesionForce,
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
      maxForce: separationForce,
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
    //edges();

    vel.add(acc);
    final dist = pos.distanceToSquared(target);
    vel.scale(dist / 700);
    if (vel.length2 > speed * speed) {
      vel.normalize();
      vel.scale(speed);
    }
    pos.add(vel);

    acc.setZero();
  }

  void paint(Canvas canvas, List<Boid> others) {
    for (Boid other in others) {
      if (other == this) continue;
      Paint paint = Paint();
      paint.color = Color(0xff000000);

      canvas.drawLine(
        Offset(pos.x, pos.y),
        Offset(other.pos.x, other.pos.y),
        paint,
      );
    }
    //return;
    canvas.drawCircle(
      Offset(pos.x, pos.y),
      5,
      Paint()..color = Color(0xFF000000),
    );
    return;
  }
}
