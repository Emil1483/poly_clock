import 'dart:math' as math;

const double EPSILON = 1.0 / 1048576.0;

class MaybeTriangle {
  final int i, j, k;
  final double x, y, r;
  MaybeTriangle({this.i, this.j, this.k, this.x, this.y, this.r});
}

List<List<double>> supertriangle(List<List<double>> vertices) {
  double xmin = double.infinity;
  double ymin = double.infinity;
  double xmax = double.infinity;
  double ymax = double.infinity;

  for (List<double> vertex in vertices) {
    if (vertex[0] < xmin) xmin = vertex[0];
    if (vertex[0] > xmax) xmax = vertex[0];
    if (vertex[1] < ymin) ymin = vertex[1];
    if (vertex[1] > ymax) ymax = vertex[1];
  }

  final double dx = xmax - xmin;
  final double dy = ymax - ymin;
  final double dmax = math.max(dx, dy);
  final double xmid = xmin + dx * 0.5;
  final double ymid = ymin + dy * 0.5;

  return [
    [xmid - 20 * dmax, ymid - dmax],
    [xmid, ymid + 20 * dmax],
    [xmid + 20 * dmax, ymid - dmax],
  ];
}

MaybeTriangle circumcircle(List<List<double>> vertices, int i, int j, int k) {
  final double x1 = vertices[i][0];
  final double y1 = vertices[i][1];
  final double x2 = vertices[j][0];
  final double y2 = vertices[j][1];
  final double x3 = vertices[k][0];
  final double y3 = vertices[k][1];
  final double fabsy1y2 = (y1 - y2).abs();
  final double fabsy2y3 = (y2 - y3).abs();

  if (fabsy1y2 < EPSILON && fabsy2y3 < EPSILON) return null;

  double xc;
  double yc;

  if (fabsy1y2 < EPSILON) {
    final double m2 = -((x3 - x2) / (y3 - y2));
    final double mx2 = (x2 + x3) / 2.0;
    final double my2 = (y2 + y3) / 2.0;
    xc = (x2 + x1) / 2.0;
    yc = m2 * (xc - mx2) + my2;
  } else if (fabsy2y3 < EPSILON) {
    final double m1 = -((x2 - x1) / (y2 - y1));
    final double mx1 = (x1 + x2) / 2.0;
    final double my1 = (y1 + y2) / 2.0;
    xc = (x3 + x2) / 2.0;
    yc = m1 * (xc - mx1) + my1;
  } else {
    final double m1 = -((x2 - x1) / (y2 - y1));
    final double m2 = -((x3 - x2) / (y3 - y2));
    final double mx1 = (x1 + x2) / 2.0;
    final double mx2 = (x2 + x3) / 2.0;
    final double my1 = (y1 + y2) / 2.0;
    final double my2 = (y2 + y3) / 2.0;
    xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2);
    yc = (fabsy1y2 > fabsy2y3) ? m1 * (xc - mx1) + my1 : m2 * (xc - mx2) + my2;
  }

  final double dx = x2 - xc;
  final double dy = y2 - yc;
  return MaybeTriangle(i: i, j: j, k: k, x: xc, y: yc, r: dx * dx + dy * dy);
}

void depup(List<double> edges) {
  for (int j = edges.length; j >= 2;) {
    final double b = edges[--j];
    final double a = edges[--j];
    for (int i = j; i >= 2;) {
      final double n = edges[--i];
      final double m = edges[--i];
      if ((a == m && b == n) || (a == n && b == m)) {
        edges..removeAt(j + 1)..removeAt(j);
        edges..removeAt(i + 1)..removeAt(i);
        break;
      }
    }
  }
}
