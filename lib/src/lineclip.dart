class Point {
  final double x, y;
  Point(this.x, this.y);

  @override
  String toString() => '[$x, $y]';
}

typedef BBox = List<double>; // [minX, minY, maxX, maxY]

// Bit code reflects the point position relative to the bbox
int bitCode(Point p, BBox bbox) {
  int code = 0;
  if (p.x < bbox[0]) code |= 1; // left
  else if (p.x > bbox[2]) code |= 2; // right
  if (p.y < bbox[1]) code |= 4; // bottom
  else if (p.y > bbox[3]) code |= 8; // top
  return code;
}

// Intersection of a segment against one of the bbox edges
Point intersect(Point a, Point b, int edge, BBox bbox) {
  if ((edge & 8) != 0) {
    // top
    double x = a.x + (b.x - a.x) * (bbox[3] - a.y) / (b.y - a.y);
    return Point(x, bbox[3]);
  } else if ((edge & 4) != 0) {
    // bottom
    double x = a.x + (b.x - a.x) * (bbox[1] - a.y) / (b.y - a.y);
    return Point(x, bbox[1]);
  } else if ((edge & 2) != 0) {
    // right
    double y = a.y + (b.y - a.y) * (bbox[2] - a.x) / (b.x - a.x);
    return Point(bbox[2], y);
  } else if ((edge & 1) != 0) {
    // left
    double y = a.y + (b.y - a.y) * (bbox[0] - a.x) / (b.x - a.x);
    return Point(bbox[0], y);
  }
  throw Exception("No intersection found");
}

// Cohen-Sutherland line clipping for polylines
List<List<Point>> lineclip(List<Point> points, BBox bbox, [List<List<Point>>? result]) {
  int len = points.length;
  int codeA = bitCode(points[0], bbox);
  List<Point> part = [];
  result ??= [];

  for (int i = 1; i < len; i++) {
    Point a = points[i - 1];
    Point b = points[i];
    int codeB = bitCode(b, bbox);
    int lastCode = codeB;

    while (true) {
      if ((codeA | codeB) == 0) {
        part.add(a);
        if (codeB != lastCode) {
          part.add(b);
          if (i < len - 1) {
            result.add(List<Point>.from(part));
            part = [];
          }
        } else if (i == len - 1) {
          part.add(b);
        }
        break;
      } else if ((codeA & codeB) != 0) {
        break;
      } else if (codeA != 0) {
        a = intersect(a, b, codeA, bbox);
        codeA = bitCode(a, bbox);
      } else {
        b = intersect(a, b, codeB, bbox);
        codeB = bitCode(b, bbox);
      }
    }
    codeA = lastCode;
  }

  if (part.isNotEmpty) result.add(List<Point>.from(part));
  return result;
}

// Sutherland-Hodgman polygon clipping
List<Point> polygonclip(List<Point> points, BBox bbox) {
  List<Point> result = [];
  int edge;
  Point prev;
  bool prevInside;
  int i;
  Point p;
  bool inside;

  for (edge = 1; edge <= 8; edge *= 2) {
    result = [];
    prev = points[points.length - 1];
    prevInside = (bitCode(prev, bbox) & edge) == 0;

    for (i = 0; i < points.length; i++) {
      p = points[i];
      inside = (bitCode(p, bbox) & edge) == 0;

      if (inside != prevInside) {
        result.add(intersect(prev, p, edge, bbox));
      }
      if (inside) result.add(p);

      prev = p;
      prevInside = inside;
    }

    points = List<Point>.from(result);

    if (points.isEmpty) break;
  }

  return result;
}