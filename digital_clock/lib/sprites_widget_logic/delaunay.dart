import "dart:math" as Math;
 
const EPSILON = 1.0 / 1048576.0;
 
class MaybeTriangle {
  double i, j, k, x, y, r;
  MaybeTriangle({this.i, this.j, this.k, this.x, this.y, this.r});
}
 
List<List<double>> supertriangle(List<List<double>> vertices) {
  double xmin = double.infinity,
      ymin = double.infinity,
      xmax = double.negativeInfinity,
      ymax = double.negativeInfinity,
      dx,
      dy,
      dmax,
      xmid,
      ymid;
 
  int i = 0;
 
  for (i = vertices.length - 1; i >= 0; i--) {
    if (vertices[i][0] < xmin) xmin = vertices[i][0];
    if (vertices[i][0] > xmax) xmax = vertices[i][0];
    if (vertices[i][1] < ymin) ymin = vertices[i][1];
    if (vertices[i][1] > ymax) ymax = vertices[i][1];
  }
 
  dx = xmax - xmin;
  dy = ymax - ymin;
  dmax = Math.max(dx, dy);
  xmid = xmin + dx * 0.5;
  ymid = ymin + dy * 0.5;
 
  return [
    [xmid - 20 * dmax, ymid - dmax],
    [xmid, ymid + 20 * dmax],
    [xmid + 20 * dmax, ymid - dmax]
  ];
}
 
MaybeTriangle circumcircle(List<List<double>> vertices, double i, double j, double k) {
  double x1 = vertices[i.toInt()][0],
      y1 = vertices[i.toInt()][1],
      x2 = vertices[j.toInt()][0],
      y2 = vertices[j.toInt()][1],
      x3 = vertices[k.toInt()][0],
      y3 = vertices[k.toInt()][1],
      fabsy1y2 = (y1 - y2).abs(),
      fabsy2y3 = (y2 - y3).abs(),
      xc,
      yc,
      m1,
      m2,
      mx1,
      mx2,
      my1,
      my2,
      dx,
      dy;
 
  /* Check for coincident points */
  if (fabsy1y2 < EPSILON && fabsy2y3 < EPSILON) throw CoincidentPoint();
 
  if (fabsy1y2 < EPSILON) {
    m2 = -((x3 - x2) / (y3 - y2));
    mx2 = (x2 + x3) / 2.0;
    my2 = (y2 + y3) / 2.0;
    xc = (x2 + x1) / 2.0;
    yc = m2 * (xc - mx2) + my2;
  } else if (fabsy2y3 < EPSILON) {
    m1 = -((x2 - x1) / (y2 - y1));
    mx1 = (x1 + x2) / 2.0;
    my1 = (y1 + y2) / 2.0;
    xc = (x3 + x2) / 2.0;
    yc = m1 * (xc - mx1) + my1;
  } else {
    m1 = -((x2 - x1) / (y2 - y1));
    m2 = -((x3 - x2) / (y3 - y2));
    mx1 = (x1 + x2) / 2.0;
    mx2 = (x2 + x3) / 2.0;
    my1 = (y1 + y2) / 2.0;
    my2 = (y2 + y3) / 2.0;
    xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2);
    yc = (fabsy1y2 > fabsy2y3) ? m1 * (xc - mx1) + my1 : m2 * (xc - mx2) + my2;
  }
 
  dx = x2 - xc;
  dy = y2 - yc;
  return MaybeTriangle(i: i, j: j, k: k, x: xc, y: yc, r: dx * dx + dy * dy);
}
 
void dedup(List<double> edges) {
  int i, j;
  double a, b, m, n;
 
  for (j = edges.length; j > 0;) {
    b = edges[--j];
    a = edges[--j];
 
    for (i = j; i > 0;) {
      n = edges[--i];
      m = edges[--i];
 
      if ((a == m && b == n) || (a == n && b == m)) {
        edges..remove(j)..remove(j + 1);
        edges..remove(i)..remove(i + 1);
        break;
      }
    }
  }
}
 
class Delaunay {
  static List<dynamic> triangulate(List<List<double>> vertices, Object key) {
    int n = vertices.length, i, j;
    double dx, dy, a, b, c;
    List<int> indices;
    List<double> edges, output = [];
    List<MaybeTriangle> open, closed;
    List<List<double>> st;
 
    /* Bail if there aren't enough vertices to form any triangles. */
    if (n < 3) return [];
 
    /* Slice out the actual vertices from the passed objects. (Duplicate the
       * array even if we don't, though, since we need to make a supertriangle
       * later on!) */
    vertices = List.from(vertices);
 
    /*
     *  This is unavailable until a proper type for vertices can be determined.
     *  Everything else suggests it is List<List<double>>, but that is incompatible with this logic.
      if(key != null)
        for(i = n; i>0; i--)
          vertices[i] = vertices[i][key];
    */
 
    /* Make an array of indices into the vertex array, sorted by the
       * vertices' x-position. Force stable sorting by comparing indices if
       * the x-positions are equal. */
    indices = List(n);
 
    for (i = n-1; i >= 0; i--) indices[i] = i;
 
    indices.sort((i, j) {
      double diff = vertices[j][0] - vertices[i][0];
      return diff == 0.0 ? i - j : diff.round();
    });
 
    /* Next, find the vertices of the supertriangle (which contains all other
       * triangles), and append them onto the end of a (copy of) the vertex
       * array. */
    st = supertriangle(vertices);
    vertices.addAll([st[0], st[1], st[2]]);
 
    /* Initialize the open list (containing the supertriangle and nothing
       * else) and the closed list (which is empty since we havn't processed
       * any triangles yet). */
    open = [circumcircle(vertices, n + 0.0, n + 1.0, n + 2.0)];
    closed = [];
    edges = [];
 
    /* Incrementally add each vertex to the mesh. */
    for (i = indices.length - 1; i >= 0; i--) {
      edges.length = 0;
      c = indices[i].toDouble();
 
      /* For each open triangle, check to see if the current point is
         * inside it's circumcircle. If it is, remove the triangle and add
         * it's edges to an edge list. */
      for (j = open.length - 1; j >= 0; j--) {
        /* If this point is to the right of this triangle's circumcircle,
           * then this triangle should never get checked again. Remove it
           * from the open list, add it to the closed list, and skip. */
        dx = vertices[c.toInt()][0] - open[j].x;
        if (dx > 0.0 && dx * dx > open[j].r) {
          closed.add(open[j]);
          open.remove(j);
          continue;
        }
 
        /* If we're outside the circumcircle, skip this triangle. */
        dy = vertices[c.toInt()][1] - open[j].y;
        if (dx * dx + dy * dy - open[j].r > EPSILON) continue;
 
        /* Remove the triangle and add it's edges to the edge list. */
        edges.addAll([open[j].i, open[j].j, open[j].j, open[j].k, open[j].k, open[j].i]);
        open.remove(j);
      }
 
      /* Remove any doubled edges. */
      dedup(edges);
 
      /* Add a new triangle for each edge. */
      for (j = edges.length; j >= 2;) {
        b = edges[--j];
        a = edges[--j];
        open.add(circumcircle(vertices, a, b, c));
      }
    }
 
    /* Copy any remaining open triangles to the closed list, and then
       * remove any triangles that share a vertex with the supertriangle,
       * building a list of triplets that represent triangles. */
    for (i = open.length - 1; i >= 0; i--) closed.add(open[i]);
    open.length = 0;
 
    for (i = closed.length - 1; i >= 0; i--)
      if (closed[i].i < n && closed[i].j < n && closed[i].k < n) output.addAll([closed[i].i, closed[i].j, closed[i].k]);
 
    /* Yay, we're done! */
    return output;
  }
 
  List<double> contains(List<List<double>> tri, List<double> p) {
    /* Bounding box test first, for quick rejections. */
    if ((p[0] < tri[0][0] && p[0] < tri[1][0] && p[0] < tri[2][0]) ||
        (p[0] > tri[0][0] && p[0] > tri[1][0] && p[0] > tri[2][0]) ||
        (p[1] < tri[0][1] && p[1] < tri[1][1] && p[1] < tri[2][1]) ||
        (p[1] > tri[0][1] && p[1] > tri[1][1] && p[1] > tri[2][1])) return null;
 
    double a = tri[1][0] - tri[0][0],
        b = tri[2][0] - tri[0][0],
        c = tri[1][1] - tri[0][1],
        d = tri[2][1] - tri[0][1],
        i = a * d - b * c;
 
    /* Degenerate tri. */
    if (i == 0.0) return null;
 
    double u = (d * (p[0] - tri[0][0]) - b * (p[1] - tri[0][1])) / i,
        v = (a * (p[1] - tri[0][1]) - c * (p[0] - tri[0][0])) / i;
 
    /* If we're outside the tri, fail. */
    if (u < 0.0 || v < 0.0 || (u + v) > 1.0) return null;
 
    return [u, v];
  }
}
 
class CoincidentPoint implements Exception {}