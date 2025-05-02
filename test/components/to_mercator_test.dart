import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/transform.dart';

void main() {
  group('Mercator Projection', () {
    test('should convert a Position from WGS84 to Web Mercator', () {
      final wgs84 = Position.of([0, 0]); // Null Island
      final mercator = geoToMercator(wgs84) as Position;
      
      expect(mercator[0], closeTo(0, 1e-9)); // At null island, x should be very close to 0
      expect(mercator[1], closeTo(0, 1e-9)); // At null island, y should be very close to 0
    });
    
    test('should preserve altitude when converting Position', () {
      final wgs84 = Position.of([0, 0, 100]); // Null Island with altitude
      final mercator = geoToMercator(wgs84) as Position;
      
      expect(mercator.length, equals(3));
      expect(mercator[2], equals(100));
    });
    
    test('should convert a Point from WGS84 to Web Mercator', () {
      final point = Point(coordinates: Position.of([10, 20]));
      final mercatorPoint = geoToMercator(point, mutate: false) as Point;
      
      // Compare with direct conversion
      final expectedCoords = geoToMercator(point.coordinates) as Position;
      
      expect(mercatorPoint.coordinates[0], closeTo(expectedCoords[0]?.toDouble() ?? 0.0, 0.001));
      expect(mercatorPoint.coordinates[1], closeTo(expectedCoords[1]?.toDouble() ?? 0.0, 0.001));
    });
    
    test('should convert a LineString from WGS84 to Web Mercator', () {
      final lineString = LineString(coordinates: [
        Position.of([0, 0]),
        Position.of([10, 10])
      ]);
      
      final mercatorLineString = geoToMercator(lineString, mutate: false) as LineString;
      
      // Check first point
      final expectedFirstCoords = geoToMercator(lineString.coordinates[0]) as Position;
      expect(mercatorLineString.coordinates[0][0], closeTo(expectedFirstCoords[0]?.toDouble() ?? 0.0, 0.001));
      expect(mercatorLineString.coordinates[0][1], closeTo(expectedFirstCoords[1]?.toDouble() ?? 0.0, 0.001));
      
      // Check second point
      final expectedSecondCoords = geoToMercator(lineString.coordinates[1]) as Position;
      expect(mercatorLineString.coordinates[1][0], closeTo(expectedSecondCoords[0]?.toDouble() ?? 0.0, 0.001));
      expect(mercatorLineString.coordinates[1][1], closeTo(expectedSecondCoords[1]?.toDouble() ?? 0.0, 0.001));
    });
    
    test('should convert a Polygon from WGS84 to Web Mercator', () {
      final polygon = Polygon(coordinates: [
        [
          Position.of([0, 0]),
          Position.of([10, 0]),
          Position.of([10, 10]),
          Position.of([0, 10]),
          Position.of([0, 0]) // Closing point
        ]
      ]);
      
      final mercatorPolygon = geoToMercator(polygon, mutate: false) as Polygon;
      
      // Check a sample point
      final expectedCoords = geoToMercator(polygon.coordinates[0][1]) as Position;
      expect(mercatorPolygon.coordinates[0][1][0], closeTo(expectedCoords[0]?.toDouble() ?? 0.0, 0.001));
      expect(mercatorPolygon.coordinates[0][1][1], closeTo(expectedCoords[1]?.toDouble() ?? 0.0, 0.001));
    });
    
    test('should convert a Feature from WGS84 to Web Mercator', () {
      final feature = Feature<Point>(
        geometry: Point(coordinates: Position.of([10, 20])),
        properties: {'name': 'Test Point'}
      );
      
      final mercatorFeature = geoToMercator(feature, mutate: false) as Feature<Point>;
      
      // Verify geometry was converted
      final expectedCoords = geoToMercator(feature.geometry!.coordinates) as Position;
      expect(mercatorFeature.geometry!.coordinates[0], closeTo(expectedCoords[0]?.toDouble() ?? 0.0, 0.001));
      expect(mercatorFeature.geometry!.coordinates[1], closeTo(expectedCoords[1]?.toDouble() ?? 0.0, 0.001));
      
      // Verify properties were preserved
      expect(mercatorFeature.properties!['name'], equals('Test Point'));
    });
    
    test('should convert a FeatureCollection from WGS84 to Web Mercator', () {
      final fc = FeatureCollection(features: [
        Feature<Point>(
          geometry: Point(coordinates: Position.of([10, 20])),
          properties: {'name': 'Point 1'}
        ),
        Feature<Point>(
          geometry: Point(coordinates: Position.of([20, 30])),
          properties: {'name': 'Point 2'}
        )
      ]);
      
      final mercatorFc = geoToMercator(fc, mutate: false) as FeatureCollection;
      
      // Verify both features were converted
      expect(mercatorFc.features.length, equals(2));
      
      // Check first feature
      final expectedCoords1 = geoToMercator(fc.features[0].geometry!.coordinates) as Position;
      final point1 = mercatorFc.features[0].geometry as Point;
      expect(point1.coordinates[0], closeTo(expectedCoords1[0]?.toDouble() ?? 0.0, 0.001));
      expect(point1.coordinates[1], closeTo(expectedCoords1[1]?.toDouble() ?? 0.0, 0.001));
      
      // Verify properties were preserved
      expect(mercatorFc.features[0].properties!['name'], equals('Point 1'));
      expect(mercatorFc.features[1].properties!['name'], equals('Point 2'));
    });
    
    test('should throw for unsupported input types', () {
      expect(() => geoToMercator("not a GeoJSON object"), throwsA(isA<ArgumentError>()));
    });
    
    test('should respect mutate option for performance', () {
      final original = Point(coordinates: Position.of([10, 20]));
      final clone = original.clone();
      
      // With mutate: false
      final withoutMutate = geoToMercator(original, mutate: false) as Point;
      expect(original.coordinates[0], equals(clone.coordinates[0])); // Original unchanged
      
      // With mutate: true
      final withMutate = geoToMercator(original, mutate: true) as Point;
      expect(original.coordinates[0], equals(withMutate.coordinates[0])); // Original changed
      expect(original.coordinates[0], isNot(equals(clone.coordinates[0]))); // Original different from original clone
    });
  });
}
