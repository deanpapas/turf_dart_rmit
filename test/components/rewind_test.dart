import 'package:turf/rewind.dart';
import 'package:test/test.dart';
import 'package:turf/turf.dart';
void main() {
  group('Rewind function tests', () {
    final linestring = Feature<LineString>(
      geometry: LineString(
        coordinates: [
            Position(0, 0),
            Position(1, 1),
            Position(2, 2)
          ],
        ),
      );

    final linestringResult = rewind(linestring, reverse: false);
    final LineString? linestringResultGeometry = linestringResult is Feature<LineString> ? linestringResult.geometry : null;
  test('Testing LineString rewind + Returns a LineString', () {
    // Check that function returns a linestring 
    expect(linestringResult, isA<Feature<LineString>>());

    // Check that function works on a LineString
    expect(linestringResultGeometry!.coordinates, equals(linestring.geometry?.coordinates.reversed.toList())); 
    }
  );



    final polygon = Feature<Polygon> (
      geometry: Polygon(
        coordinates: [
          [
            Position(0, 0),
            Position(1, 1),
            Position(2, 2),
            Position(0, 0)
          ],
        ],
      ),
    );

    final polygonResult = rewind(polygon, reverse: true);
    final Polygon? polygonResultGeometry = polygonResult is Feature<Polygon> ? polygonResult.geometry : null;
  test('Testing Polygon rewind + Returning a Polygon', () {
    // Check that function returns a polygon
    expect(polygonResult, isA<Feature<Polygon>>());

    // Check that function works on a Polygon
    expect(polygonResultGeometry!.coordinates, equals(polygon.geometry?.coordinates.reversed.toList())); 
    }
  );

    final multilinestring = Feature<MultiLineString>(
      geometry: MultiLineString(
        coordinates: [
          [
            Position(0, 0),
            Position(1, 1),
            Position(2, 2)
          ],
          [
            Position(1, 0),
            Position(3, 2),
            Position(5, 4)
          ],
        ],
      ),
    );

    final multilinestringResult = rewind(multilinestring, reverse: false);
    final MultiLineString? multilinestringResultGeometry = multilinestringResult is Feature<MultiLineString> ? multilinestring.geometry : null; 
  test('Testing MultiLineString rewind + Returning a MultiLinestring', () {
    // Check function returns a multilinestring
    expect(multilinestringResult, isA<Feature<MultiLineString>>());
    // Check that function works on a MultiLineString
    expect(multilinestringResultGeometry!.coordinates, equals(multilinestring.geometry?.coordinates.reversed.toList()));
  });

  test('Testing MultiPolygon rewind + returning a MultiPolygon', () {
    // Check function returns a multipolygon

    // Check that function works on a Multipolygon
  });

  }
  );
}