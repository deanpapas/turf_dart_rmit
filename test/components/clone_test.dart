import 'package:test/test.dart';
import 'package:turf/clone.dart';

void main() {
  group('Simple GeoJSON clone tests', () {
    test('Clones a simple Point feature', () {
      final input = {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [102.0, 0.5]
        },
        "properties": {"prop0": "value0"}
      };

      final result = clone(input);

      expect(result, equals(input));
      expect(identical(result, input), isFalse);
      expect(identical(result['geometry'], input['geometry']), isFalse);
      expect(identical(result['properties'], input['properties']), isFalse);
    });

    test('Clones a simple LineString feature', () {
      final input = {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [102.0, 0.0],
            [103.0, 1.0]
          ]
        },
        "properties": {}
      };

      final result = clone(input);

      expect(result, equals(input));
      expect(identical(result, input), isFalse);
      expect(identical(result['geometry'], input['geometry']), isFalse);
      expect(identical(result['properties'], input['properties']), isFalse);
      expect(identical((result['geometry'] as Map)['coordinates'], (input['geometry'] as Map)['coordinates']), isFalse);
    });

    test('Clones a FeatureCollection with one Point feature', () {
      final input = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [102.0, 0.5]
            },
            "properties": {"prop0": "value0"}
          }
        ]
      };

      final result = clone(input);

      expect(result, equals(input));
      expect(identical(result, input), isFalse);
      expect(identical(result['features'], input['features']), isFalse);
      expect(identical((result['features'] as List)[0], (input['features'] as List)[0]), isFalse);
      expect(identical(((result['features'] as List)[0] as Map)['geometry'], ((input['features'] as List)[0] as Map)['geometry']), isFalse);
      expect(identical(((result['features'] as List)[0] as Map)['properties'], ((input['features'] as List)[0] as Map)['properties']), isFalse);
    });
  });
}