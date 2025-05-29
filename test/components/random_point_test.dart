import 'package:test/test.dart';
import 'package:turf/random_point.dart';

void main() {
  group('Random Point Tests', () {


    test('Confirming generation of a single random Point', () {
      
      BBox bbox = BBox(100.0, -24.0, 110.0, -23.0);
      FeatureCollection<Point> points = randomPoint(1, bbox: bbox);

      expect(points.features.length, equals(1));
      expect(points.features.first.geometry?.coordinates, isNotNull);
      
    });


    test('Confirming generation of multiple random Points', () {
      BBox bbox = BBox(100.0, -24.0, 110.0, -23.0);
      FeatureCollection<Point> points = randomPoint(5, bbox: bbox);

      expect(points.features.length, equals(5));
      expect(points.features.first.geometry?.coordinates, isNotNull);

    });

    test('Generating a random point within a bounding box', () {
      BBox bbox = BBox(100.0, -24.0, 110.0, -23.0);
      FeatureCollection<Point> point = randomPoint(1, bbox: bbox);

      expect(point.features.first.geometry?.coordinates.lng, greaterThanOrEqualTo(bbox[0]!));
      expect(point.features.first.geometry?.coordinates.lng, lessThanOrEqualTo(bbox[2]!));
      expect(point.features.first.geometry?.coordinates.lat, greaterThanOrEqualTo(bbox[1]!));
      expect(point.features.first.geometry?.coordinates.lat, lessThanOrEqualTo(bbox[3]!));
    });

    test('Confirming Point feature', () {
      FeatureCollection<Point> points = randomPoint(1);
      expect(points, isA<FeatureCollection<Point>>());

    });
  });
}