import 'package:test/test.dart';
import 'package:turf/helpers.dart';

void main() {
  test('Check Feature properties', () {
    // Create a feature to check available properties
    var feature = Feature<Point>(
      geometry: Point(coordinates: Position(1, 2)),
      properties: {'name': 'Test Point'},
      id: 'point1'
    );
    
    // Print out available properties
    print(feature.toString());
    
    // Test what we can access
    expect(feature.geometry, isA<Point>());
    expect(feature.properties, equals({'name': 'Test Point'}));
    expect(feature.id, equals('point1'));
  });
}
