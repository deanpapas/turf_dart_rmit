import 'package:turf/rewind.dart';
import 'package:test/test.dart';

void main() {
  group('Rewind function tests', () {
    // Line String tests
    final linestring = LineString(
      coordinates: [
        Position(0, 0),
        Position(1, 0),
        Position(1, 1),
        Position(0, 1),
        Position(0, 0)
      ],
    );

    final lineStringResult = rewind(linestring, reverse: true) as LineString;

    test('Testing LineString rewind + Returns a LineString', () {
      // Check that function returns a linestring
      expect(lineStringResult, isA<LineString>());

      // Check that function works on a LineString
      expect(lineStringResult.coordinates,
          equals(linestring.coordinates.reversed.toList()));
    });

    // Polygon tests
    final polygon = Polygon(coordinates: [
      [Position(0, 0), Position(1, 1), Position(2, 2), Position(0, 0)],
    ]);

    final polygonResult = rewind(polygon, reverse: true) as Polygon;

    test('Testing Polygon rewind + Returning a Polygon', () {
      // Check that function returns a polygon
      expect(polygonResult, isA<Polygon>());

      // Check that winding works + polygon is still valid
      expect(
          polygonResult.coordinates.length, equals(polygon.coordinates.length));
      expect(polygonResult.coordinates[0].length,
          equals(polygon.coordinates[0].length));
    });

    // MultiLineString tests
    final multilinestring = MultiLineString(
      coordinates: [
        [Position(0, 0), Position(1, 1), Position(2, 2)],
        [Position(1, 0), Position(3, 2), Position(5, 4)],
      ],
    );

    final multiLineStringResult =
        rewind(multilinestring, reverse: true) as MultiLineString;

    // Individually reversing each linestring (else the whole multilinestring is reversed
    final multiLineStringReversed = multilinestring.coordinates.map((coords) {
      return coords.reversed.toList();
    }).toList();

    test('Testing MultiLineString rewind + Returning a MultiLinestring', () {
      // Check function returns a multilinestring
      expect(multiLineStringResult, isA<MultiLineString>());
      // Check that function works on a MultiLineString
      expect(
          multiLineStringResult.coordinates, equals(multiLineStringReversed));
    });

    // Multi Polygon Tests
    final multipolygon = MultiPolygon(
      coordinates: [
        [
          [
            Position(0, 0),
            Position(1, 0),
            Position(1, 1),
            Position(0, 1),
            Position(0, 0)
          ],
        ],
        [
          [
            Position(2, 2),
            Position(3, 2),
            Position(3, 3),
            Position(2, 3),
            Position(2, 2)
          ],
        ]
      ],
    );

    final multiPolygonResult =
        rewind(multipolygon, reverse: true) as MultiPolygon;
    test('Testing MultiPolygon rewind + returning a MultiPolygon', () {
      // Check function returns a MultiPolygon
      expect(multiPolygonResult, isA<MultiPolygon>());

      // Check that function works on a MultiPolygon
      expect(multiPolygonResult.coordinates, isA<List<List<List<Position>>>>());
    });
  });
}
