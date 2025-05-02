import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/transform.dart';

void main() {
  group('Web Mercator to WGS84 Conversion', () {
    test('should convert a Position from Web Mercator to WGS84', () {
      // A point in Web Mercator (Null Island)
      final mercator = Position.of([0, 0]);
      final wgs84 = geoToWgs84(mercator) as Position;
      
      expect(wgs84[0], closeTo(0, 1e-9)); // At null island, longitude should be very close to 0
      expect(wgs84[1], closeTo(0, 1e-9)); // At null island, latitude should be very close to 0
    });
    
    test('should preserve altitude when converting Position', () {
      final mercator = Position.of([0, 0, 100]); // Null Island with altitude
      final wgs84 = geoToWgs84(mercator) as Position;
      
      expect(wgs84.length, equals(3));
      expect(wgs84[2], equals(100));
    });
    
    test('should convert a Point from Web Mercator to WGS84', () {
      // New York in Web Mercator approximately
      final mercatorPoint = Point(coordinates: Position.of([-8237642.31, 4970241.32]));
      final wgs84Point = geoToWgs84(mercatorPoint, mutate: false) as Point;
      
      // Verify coordinates are in expected WGS84 range
      expect(wgs84Point.coordinates[0], closeTo(-74.0, 0.5)); // Approx. longitude of New York
      expect(wgs84Point.coordinates[1], closeTo(40.7, 0.5)); // Approx. latitude of New York
    });
    
    test('should convert a LineString from Web Mercator to WGS84', () {
      final mercatorLineString = LineString(coordinates: [
        // Points in Web Mercator
        Position.of([0, 0]),
        Position.of([1113195, 1118890])
      ]);
      
      final wgs84LineString = geoToWgs84(mercatorLineString, mutate: false) as LineString;
      
      // Check first point at Null Island
      expect(wgs84LineString.coordinates[0][0], closeTo(0, 1e-9)); 
      expect(wgs84LineString.coordinates[0][1], closeTo(0, 1e-9));
      
      // Check second point is in expected WGS84 range
      expect(wgs84LineString.coordinates[1][0], closeTo(10.0, 0.5));
      expect(wgs84LineString.coordinates[1][1], closeTo(10.0, 0.5));
    });
    
    test('should convert a Polygon from Web Mercator to WGS84', () {
      final mercatorPolygon = Polygon(coordinates: [
        [
          Position.of([0, 0]),
          Position.of([1113195, 0]),
          Position.of([1113195, 1118890]),
          Position.of([0, 1118890]),
          Position.of([0, 0]) // Closing point
        ]
      ]);
      
      final wgs84Polygon = geoToWgs84(mercatorPolygon, mutate: false) as Polygon;
      
      // Check corners of polygon
      expect(wgs84Polygon.coordinates[0][0][0], closeTo(0, 1e-9));
      expect(wgs84Polygon.coordinates[0][0][1], closeTo(0, 1e-9));
      
      expect(wgs84Polygon.coordinates[0][2][0], closeTo(10.0, 0.5));
      expect(wgs84Polygon.coordinates[0][2][1], closeTo(10.0, 0.5));
    });
    
    test('should convert a Feature from Web Mercator to WGS84', () {
      final mercatorFeature = Feature<Point>(
        geometry: Point(coordinates: Position.of([15550408.91, 4257980.73, 5.0])), // Tokyo in Web Mercator
        properties: {'name': 'Tokyo', 'country': 'Japan'}
      );
      
      final wgs84Feature = geoToWgs84(mercatorFeature, mutate: false) as Feature<Point>;
      
      // Verify geometry was converted to approximately Tokyo's WGS84 coordinates
      expect(wgs84Feature.geometry!.coordinates[0], closeTo(139.69, 0.5)); // Tokyo longitude
      expect(wgs84Feature.geometry!.coordinates[1], closeTo(35.68, 0.5)); // Tokyo latitude
      expect(wgs84Feature.geometry!.coordinates[2], equals(5.0)); // Preserve altitude
      
      // Verify properties were preserved
      expect(wgs84Feature.properties!['name'], equals('Tokyo'));
      expect(wgs84Feature.properties!['country'], equals('Japan'));
    });
    
    test('should convert a FeatureCollection from Web Mercator to WGS84', () {
      final mercatorFc = FeatureCollection(features: [
        // Paris in Web Mercator
        Feature<Point>(
          geometry: Point(coordinates: Position.of([261865.42, 6250566.48])),
          properties: {'name': 'Paris'}
        ),
        // Moscow in Web Mercator
        Feature<Point>(
          geometry: Point(coordinates: Position.of([4187399.59, 7509720.48])),
          properties: {'name': 'Moscow'}
        )
      ]);
      
      final wgs84Fc = geoToWgs84(mercatorFc, mutate: false) as FeatureCollection;
      
      // Verify both features were converted
      expect(wgs84Fc.features.length, equals(2));
      
      // Check first feature (Paris)
      final point1 = wgs84Fc.features[0].geometry as Point;
      expect(point1.coordinates[0], closeTo(2.35, 0.5)); // Paris longitude
      expect(point1.coordinates[1], closeTo(48.85, 0.5)); // Paris latitude
      
      // Verify properties were preserved
      expect(wgs84Fc.features[0].properties!['name'], equals('Paris'));
      expect(wgs84Fc.features[1].properties!['name'], equals('Moscow'));
    });
    
    test('should throw for unsupported input types', () {
      expect(() => geoToWgs84("not a GeoJSON object"), throwsA(isA<ArgumentError>()));
    });
    
    test('should respect mutate option for performance', () {
      final original = Point(coordinates: Position.of([-8237642.31, 4970241.32]));
      final clone = original.clone();
      
      // With mutate: false
      final withoutMutate = geoToWgs84(original, mutate: false) as Point;
      expect(original.coordinates[0], equals(clone.coordinates[0])); // Original unchanged
      
      // With mutate: true
      final withMutate = geoToWgs84(original, mutate: true) as Point;
      expect(original.coordinates[0], equals(withMutate.coordinates[0])); // Original changed
      expect(original.coordinates[0], isNot(equals(clone.coordinates[0]))); // Original different from original clone
    });
    
    test('round-trip conversion should approximately recover original coordinates', () {
      // Start with WGS84
      final startWgs84 = Position.of([10, 20]);
      
      // Convert to Mercator
      final mercator = geoToMercator(startWgs84) as Position;
      
      // Convert back to WGS84
      final endWgs84 = geoToWgs84(mercator) as Position;
      
      // Should be close to original
      expect(endWgs84[0], closeTo(startWgs84[0]?.toDouble() ?? 0.0, 0.001));
      expect(endWgs84[1], closeTo(startWgs84[1]?.toDouble() ?? 0.0, 0.001));
    });
  });
}
