import 'package:turf/helpers.dart';
import 'package:turf/transform.dart';

void main() {
  print('=== Web Mercator Transformations Examples ===\n');

  // Position conversion example
  final wgs84Position = Position.of([-74.006, 40.7128, 10.0]); // New York City
  print('WGS84 Position: $wgs84Position');
  
  final mercatorPosition = geoToMercator(wgs84Position) as Position;
  print('Mercator Position: $mercatorPosition');
  
  final backToWgs84 = geoToWgs84(mercatorPosition) as Position;
  print('Back to WGS84: $backToWgs84\n');

  // Point geometry conversion
  final point = Point(coordinates: Position.of([151.2093, -33.8688, 20.0])); // Sydney
  print('WGS84 Point: $point');
  
  final mercatorPoint = geoToMercator(point) as Point;
  print('Mercator Point: $mercatorPoint');
  
  final wgs84Point = geoToWgs84(mercatorPoint) as Point;
  print('Back to WGS84 Point: $wgs84Point\n');

  // LineString example
  final lineString = LineString(coordinates: [
    Position.of([0, 0]),
    Position.of([10, 10]),
    Position.of([20, 0])
  ]);
  print('WGS84 LineString: $lineString');
  
  final mercatorLineString = geoToMercator(lineString) as LineString;
  print('Mercator LineString: $mercatorLineString');
  
  final wgs84LineString = geoToWgs84(mercatorLineString) as LineString;
  print('Back to WGS84 LineString: $wgs84LineString\n');

  // Feature example
  final feature = Feature<Point>(
    geometry: Point(coordinates: Position.of([139.6917, 35.6895, 5.0])), // Tokyo
    properties: {'name': 'Tokyo', 'country': 'Japan'}
  );
  print('WGS84 Feature: $feature');
  
  // Use mutate: false to keep the original object unchanged
  final mercatorFeature = geoToMercator(feature, mutate: false) as Feature<Point>;
  print('Mercator Feature: $mercatorFeature');
  print('Original feature unchanged: ${feature.geometry!.coordinates != mercatorFeature.geometry!.coordinates}');
  
  // Use mutate: true to modify the original object (better performance)
  final clonedFeature = feature.clone();
  final mutatedFeature = geoToMercator(clonedFeature, mutate: true) as Feature<Point>;
  print('Mutated Feature: $mutatedFeature');
  print('Original feature modified (when mutate=true): ${clonedFeature.geometry!.coordinates == mutatedFeature.geometry!.coordinates}\n');

  // FeatureCollection example
  final featureCollection = FeatureCollection(features: [
    Feature<Point>(
      geometry: Point(coordinates: Position.of([2.3522, 48.8566])), // Paris
      properties: {'name': 'Paris'}
    ),
    Feature<Point>(
      geometry: Point(coordinates: Position.of([37.6173, 55.7558])), // Moscow
      properties: {'name': 'Moscow'}
    )
  ]);
  print('WGS84 FeatureCollection: $featureCollection');
  
  final mercatorFeatureCollection = geoToMercator(featureCollection) as FeatureCollection;
  print('Mercator FeatureCollection: $mercatorFeatureCollection');
  
  final wgs84FeatureCollection = geoToWgs84(mercatorFeatureCollection) as FeatureCollection;
  print('Back to WGS84 FeatureCollection: $wgs84FeatureCollection\n');

  print('=== Usage Tips ===');
  print('1. Use geoToMercator() to convert any GeoJSON object from WGS84 to Web Mercator');
  print('2. Use geoToWgs84() to convert any GeoJSON object from Web Mercator back to WGS84');
  print('3. Set mutate=true for better performance when you don\'t need to preserve the original object');
  print('4. Use as Position/Point/etc. to get the correct type back');
}
