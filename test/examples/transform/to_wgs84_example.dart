import 'package:turf/helpers.dart';
import 'package:turf/transform.dart';

void main() {
  print('=== Web Mercator to WGS84 Transformations Examples ===\n');

  // Position conversion example
  final mercatorPosition = Position.of([-8237642.31, 4970241.32, 10.0]); // New York City in Mercator
  print('Mercator Position: $mercatorPosition');
  
  final wgs84Position = geoToWgs84(mercatorPosition) as Position;
  print('WGS84 Position: $wgs84Position');
  
  final backToMercator = geoToMercator(wgs84Position) as Position;
  print('Back to Mercator: $backToMercator\n');

  // Point geometry conversion
  final mercatorPoint = Point(coordinates: Position.of([16830163.94, -3995519.76, 20.0])); // Sydney in Mercator
  print('Mercator Point: $mercatorPoint');
  
  final wgs84Point = geoToWgs84(mercatorPoint) as Point;
  print('WGS84 Point: $wgs84Point');
  
  final mercatorPointAgain = geoToMercator(wgs84Point) as Point;
  print('Back to Mercator Point: $mercatorPointAgain\n');

  // LineString example
  final mercatorLineString = LineString(coordinates: [
    Position.of([0, 0]),
    Position.of([1113195, 1118890]),
    Position.of([2226390, 0])
  ]);
  print('Mercator LineString: $mercatorLineString');
  
  final wgs84LineString = geoToWgs84(mercatorLineString) as LineString;
  print('WGS84 LineString: $wgs84LineString');
  
  final mercatorLineStringAgain = geoToMercator(wgs84LineString) as LineString;
  print('Back to Mercator LineString: $mercatorLineStringAgain\n');

  // Feature example
  final mercatorFeature = Feature<Point>(
    geometry: Point(coordinates: Position.of([15550408.91, 4257980.73, 5.0])), // Tokyo in Mercator
    properties: {'name': 'Tokyo', 'country': 'Japan'}
  );
  print('Mercator Feature: $mercatorFeature');
  
  // Use mutate: false to keep the original object unchanged
  final wgs84Feature = geoToWgs84(mercatorFeature, mutate: false) as Feature<Point>;
  print('WGS84 Feature: $wgs84Feature');
  print('Original feature unchanged: ${mercatorFeature.geometry!.coordinates != wgs84Feature.geometry!.coordinates}');
  
  // Use mutate: true to modify the original object (better performance)
  final clonedFeature = mercatorFeature.clone();
  final mutatedFeature = geoToWgs84(clonedFeature, mutate: true) as Feature<Point>;
  print('Mutated Feature: $mutatedFeature');
  print('Original feature modified (when mutate=true): ${clonedFeature.geometry!.coordinates == mutatedFeature.geometry!.coordinates}\n');

  // FeatureCollection example
  final mercatorFeatureCollection = FeatureCollection(features: [
    Feature<Point>(
      geometry: Point(coordinates: Position.of([261865.42, 6250566.48])), // Paris in Mercator
      properties: {'name': 'Paris'}
    ),
    Feature<Point>(
      geometry: Point(coordinates: Position.of([4187399.59, 7509720.48])), // Moscow in Mercator
      properties: {'name': 'Moscow'}
    )
  ]);
  print('Mercator FeatureCollection: $mercatorFeatureCollection');
  
  final wgs84FeatureCollection = geoToWgs84(mercatorFeatureCollection) as FeatureCollection;
  print('WGS84 FeatureCollection: $wgs84FeatureCollection');
  
  final mercatorFeatureCollectionAgain = geoToMercator(wgs84FeatureCollection) as FeatureCollection;
  print('Back to Mercator FeatureCollection: $mercatorFeatureCollectionAgain\n');

  print('=== Round-trip Conversion Accuracy ===');
  // Start with some WGS84 coordinates
  final originalWgs84 = Position.of([10.0, 20.0, 30.0]);
  print('Original WGS84: $originalWgs84');
  
  // Convert to Mercator
  final converted = geoToMercator(originalWgs84) as Position;
  print('Converted to Mercator: $converted');
  
  // Convert back to WGS84
  final roundTrip = geoToWgs84(converted) as Position;
  print('Converted back to WGS84: $roundTrip');
  
  // Calculate the difference (should be very small)
  final lonDiff = (originalWgs84[0]?.toDouble() ?? 0.0) - (roundTrip[0]?.toDouble() ?? 0.0);
  final latDiff = (originalWgs84[1]?.toDouble() ?? 0.0) - (roundTrip[1]?.toDouble() ?? 0.0);
  print('Longitude difference: $lonDiff°');
  print('Latitude difference: $latDiff°\n');

  print('=== Usage Tips ===');
  print('1. Use geoToWgs84() to convert any GeoJSON object from Web Mercator to WGS84');
  print('2. Use geoToMercator() to convert any GeoJSON object from WGS84 to Web Mercator');
  print('3. Set mutate=true for better performance when you don\'t need to preserve the original object');
  print('4. Use as Position/Point/etc. to get the correct type back');
  print('5. Round-trip conversions maintain high accuracy, but tiny numeric differences may occur');
}
