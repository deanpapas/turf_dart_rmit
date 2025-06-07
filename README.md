<h1 align="center">
  <br>
  <img src="https://github.com/dartclub/turf_dart/blob/main/.github/turf-logo.png" alt="TurfDart Logo" width="250">
</h1>

<h4 align="center">A <a href="https://github.com/Turfjs/turf">TurfJs</a>-like geospatial analysis library written in pure Dart.
</h4>
<br>

[![pub package](https://img.shields.io/pub/v/turf.svg)](https://pub.dev/packages/turf)
![dart unit tests](https://github.com/dartclub/turf_dart/actions/workflows/dart-unit-tests.yml/badge.svg)
![dart publish](https://github.com/dartclub/turf_dart/actions/workflows/dart-pub-publish.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![GitHub URL of Turf Dart](https://github.com/dartclub/turf_dart) 
![GitHub URL of Turf Dart RMIT](https://github.com/deanpapas/turf_dart_rmit) 

<h3>–> <a href="https://discord.gg/TcHhfTVWVK">Join our Dart / Flutter GIS Community on Discord</a> <–</h3>

TurfDart is a Dart library for [spatial analysis](https://en.wikipedia.org/wiki/Spatial_analysis). It includes traditional spatial operations, helper functions for creating GeoJSON data, and data classification and statistics tools. You can use TurfDart in your Flutter applications on the web, mobile and desktop or in pure Dart applications running on the server.

As the foundation, we are using [Geotypes](https://github.com/dartclub/geotypes), a lightweight dart library that provides a strong GeoJSON object model and fully [RFC 7946](https://tools.ietf.org/html/rfc7946) compliant serializers.

Most of the functionality is a translation from [turf.js](https://github.com/Turfjs/turf), the progress can be found [here](Progress.md).

## Get started

- Get the [Dart tools](https://dart.dev/tools)
- Install the library with `dart pub add turf`
- Import the library in your code and use it. For example:

```dart
import 'package:turf/helpers.dart';
import 'package:turf/src/line_segment.dart';

Feature<Polygon> poly = Feature<Polygon>(
  geometry: Polygon(coordinates: [
    [
      Position(0, 0),
      Position(2, 2),
      Position(0, 1),
      Position(0, 0),
    ],
    [
      Position(0, 0),
      Position(1, 1),
      Position(0, 1),
      Position(0, 0),
    ],
  ]),
);

void main() {
  var total = segmentReduce<int>(
    poly,
    (previousValue, currentSegment, initialValue, featureIndex,
        multiFeatureIndex, geometryIndex, segmentIndex) {
      if (previousValue != null) {
        previousValue++;
      }
      return previousValue;
    },
    0,
    combineNestedGeometries: false,
  );
  print(total);
  // total ==  6
}
```

## GeoJSON Object Model

![polymorphism](https://user-images.githubusercontent.com/10634693/159876354-f9da2f37-02b3-4546-b32a-c0f82c372272.png)

### Notable Design Decisions

- Nested `GeometryCollections` (as described in
  [RFC 7946 section 3.1.8](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.8))
  are _not supported_ which takes a slightly firmer stance than the "should
  avoid" language in the specification

## Tests and Benchmarks

Tests are run with `dart test` and benchmarks can be run with
`dart run benchmark`

Any new benchmarks must be named `*_benchmark.dart` and reside in the
`./benchmark` folder.
  
## CHANGELOG
## 0.0.11
- Implements square, envelope, pointonfeature, greatcircle, polgontangents, WSG84 member functions, CentreOfMass, CopyWith(options) method, toMercator member functions, bbox, GeoJSON Support for "other members", index, operation (PolygonClippingPackage), toWgs84, toMercator, Combine, Flatten, RandomPosition, RandomLineString, Flip, RandomPoint, Rewind, BboxClip, Polyclip dart testing, Polygonize, ClustersDbscan, Clone, PointsWithinPolygon, Sample [Turf_dart_rmit](https://github.com/deanpapas/turf_dart_rmit)
- Implements bbox (PolygonClippingPackage), compare (PolygonClippingPackage), constants (PolygonClippingPackage), geom-in (PolygonClippingPackage), geom-out (PolygonClippingPackage), identity (PolygonClippingPackage), orient (PolygonClippingPackage), precision (PolygonClippingPackage), segment (PolygonClippingPackage), snap (PolygonClippingPackage), sweep-events (PolygonClippingPackage), sweep-line (PolygonClippingPackage), Union, intersection [polyclip-dart](https://github.com/deanpapas/polyclip-dart)
## 0.0.10

- Implements `lineSlice` [#158](https://github.com/dartclub/turf_dart/pull/158)
- Introduce [geotypes package](https://pub.dev/packages/geotypes) for GeoJSON serialization
- Other small improvements

## 0.0.9

- Implements `length`, `along` [#153](https://github.com/dartclub/turf_dart/pull/153)
- Documentation: Improves pub.dev scores by fixing bad links in Readme.md

## 0.0.8

- Implements `transformRotate`, `rhumbDistance`, `rhumbDestination`, `centroid` [#147](https://github.com/dartclub/turf_dart/pull/147)
- Introduce `localCoordIndex` in `coordEach`
- Implements all the `boolean`* functions [#91](https://github.com/dartclub/turf_dart/pull/91)
- Implements `area` function [#123](https://github.com/dartclub/turf_dart/pull/123)
- Implements `polygonSmooth` function [#127](https://github.com/dartclub/turf_dart/pull/127)
- Fixes missing parameter in nearest point on line [#145](https://github.com/dartclub/turf_dart/pull/145)
- Other core improvements
- Support for Dart 3

## 0.0.7

- Implements `nearestPointOn(Multi)Line` [#87](https://github.com/dartclub/turf_dart/pull/87)
- Implements `explode` function [#93](https://github.com/dartclub/turf_dart/pull/93)
- Implements `bbox-polygon` and `bbox`, `center`, polyline functions [#99](https://github.com/dartclub/turf_dart/pull/99)
- Updates the `BBox`-class constructor [#100](https://github.com/dartclub/turf_dart/pull/100)
- Implements `rhumbBearing` function [#109](https://github.com/dartclub/turf_dart/pull/109)
- Implements `lineToPolygon` and `polygonToLine` functions [#104](https://github.com/dartclub/turf_dart/pull/104)
- Implements `truncate` function [#111](https://github.com/dartclub/turf_dart/pull/111)
- Implements `cleanCoord` function [#112](https://github.com/dartclub/turf_dart/pull/112)
- Some documentation & README improvements

## 0.0.6+3

- Rename examples file

## 0.0.6+2

- Added code examples
- Fixed segment * callbacks

## 0.0.6

- This is solely a quality release, without new functionality:
- Documentation: improves pub.dev scores, raised documentation coverage, fixed typos
- Return type fixes for the the meta extensions

## 0.0.5


- Implements *all* meta functions and `lineSegment`
- Adds a lot of documentation
- Several bug and type fixes

## 0.0.4

- Implements the `featureEach` and `propEach` meta function. [#24](https://github.com/dartclub/turf_dart/pull/24)
- PR [#43](https://github.com/dartclub/turf_dart/pull/43):
  - Several bugfixes with the deserialization of JSON
  - Several new constructors
  - Vector arithmetics operations

## 0.0.3

- Null-safety support

## 0.0.2+3

Implements the `geomEach` meta function. [#13](https://github.com/dartclub/turf_dart/pull/13)

## 0.0.2+1

- initialize lists and maps empty in constructors, if not provided

## 0.0.2

- normalization for coordinates (Position)
- and yes, it's still under heavy development

## 0.0.1

- Initial version, still under heavy development
