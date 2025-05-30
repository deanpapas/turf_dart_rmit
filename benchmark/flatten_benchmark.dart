import 'package:benchmark/benchmark.dart';
import 'package:turf/turf.dart';

// Feature with a MultiPolygon to flatten
final Feature<MultiPolygon> complexFeature = Feature<MultiPolygon>(
  geometry: MultiPolygon(coordinates: [
    // First polygon
    [
      [
        Position(0, 0, 5),     // With altitude
        Position(0, 10, 15),   // With altitude
        Position(10, 10, 25),  // With altitude
        Position(10, 0, 5),    // With altitude
        Position(0, 0, 5)      // With altitude
      ],
      // Hole in first polygon
      [
        Position(2, 2, 7),     // With altitude
        Position(2, 8, 12),    // With altitude
        Position(8, 8, 18),    // With altitude
        Position(8, 2, 7),     // With altitude
        Position(2, 2, 7)      // With altitude
      ]
    ],
    // Second polygon
    [
      [
        Position(20, 20, 30),  // With altitude
        Position(20, 30, 35),  // With altitude
        Position(30, 30, 40),  // With altitude
        Position(30, 20, 30),  // With altitude
        Position(20, 20, 30)   // With altitude
      ]
    ],
    // Third polygon
    [
      [
        Position(40, 40, 45),  // With altitude
        Position(40, 50, 50),  // With altitude
        Position(50, 50, 55),  // With altitude
        Position(50, 40, 45),  // With altitude
        Position(40, 40, 45)   // With altitude
      ]
    ]
  ]),
  properties: {'name': 'Complex MultiPolygon', 'tags': ['benchmark', 'turf']},
);

// Create a FeatureCollection with multiple geometry types
final FeatureCollection<GeometryObject> mixedGeometryCollection = FeatureCollection<GeometryObject>(
  features: [
    // Single Point
    Feature<Point>(
      geometry: Point(coordinates: Position(0, 0)),
      properties: {'name': 'Point 1'},
    ),
    // MultiPoint with 5 points
    Feature<MultiPoint>(
      geometry: MultiPoint(coordinates: List.generate(
        5,
        (i) => Position(i * 10, i * 5),
      )),
      properties: {'name': 'MultiPoint 1'},
    ),
    // LineString with 10 positions
    Feature<LineString>(
      geometry: LineString(coordinates: List.generate(
        10,
        (i) => Position(i * 2, i * 3),
      )),
      properties: {'name': 'LineString 1'},
    ),
    // MultiLineString with 3 lines, each having 4 positions
    Feature<MultiLineString>(
      geometry: MultiLineString(coordinates: List.generate(
        3,
        (i) => List.generate(
          4,
          (j) => Position(i * 10 + j, i * 5 + j),
        ),
      )),
      properties: {'name': 'MultiLineString 1'},
    ),
    // Polygon with outer ring and one hole
    Feature<Polygon>(
      geometry: Polygon(coordinates: [
        [
          Position(0, 0),
          Position(0, 10),
          Position(10, 10),
          Position(10, 0),
          Position(0, 0)
        ],
        [
          Position(2, 2),
          Position(2, 8),
          Position(8, 8),
          Position(8, 2),
          Position(2, 2)
        ]
      ]),
      properties: {'name': 'Polygon 1'},
    ),
    // MultiPolygon with 2 polygons
    Feature<MultiPolygon>(
      geometry: MultiPolygon(coordinates: [
        [
          [
            Position(0, 0),
            Position(0, 5),
            Position(5, 5),
            Position(5, 0),
            Position(0, 0)
          ]
        ],
        [
          [
            Position(10, 10),
            Position(10, 15),
            Position(15, 15),
            Position(15, 10),
            Position(10, 10)
          ]
        ]
      ]),
      properties: {'name': 'MultiPolygon 1'},
    ),
  ],
);

void main() {
  group('flatten', () {
    benchmark('multipolygon', () {
      flatten(complexFeature);
    });
    
    benchmark('mixed_geometry_collection', () {
      flatten(mixedGeometryCollection);
    });
  });
}
