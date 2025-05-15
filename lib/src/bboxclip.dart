// This code considers the dart port of lineclip from Mapbox
// https://github.com/Zverik/flutter_country_coder/blob/eccf7afbc13746d864b01fd581c7b785499340f0/lib/src/lineclip.dart#L8

import 'package:geotypes/geotypes.dart' show
  Feature,
  LineString,
  MultiLineString,
  MultiPolygon,
  Polygon;

import 'package:turf/bbox.dart'; 
import 'package:turf/lineclip.dart';