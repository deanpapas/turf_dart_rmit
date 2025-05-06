import 'package:turf/great_circle.dart';
import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';
import 'dart:math';

void main() {
  //First test - simple coordinates

  final start = Position(-90, 0);
  final end = Position(-80,0);

  List<List<double>> resultsFirstTest1 = [[-90.0, 0.0], [-88.0,0.0], [-86.0,0.0], [-84.0, 0.0], [-82.0, 0.0],[-80.0, 0.0]];
  List<List<double>> resultsFirstTest2 = [[-90.0, 0.0], [-89.0,0.0], [-88.0,0.0], [-87.0, 0.0], [-86.0, 0.0],[-85.0,0.0], [-84.0,0.0], [-83.0, 0.0], [-82.0, 0.0],[-81.0, 0.0], [-80.0, 0.0]];
  
  test('Great circle simple tests:', () {
    var resultFirst1 = greatCircle(start, end, npoints: 5);
    var convertedResultFirst1 = resultFirst1.geometry?.coordinates.map((pos) =>
    [double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)), double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))]).toList();
    expect(convertedResultFirst1, resultsFirstTest1);

    var resultFirst2 = greatCircle(start, end, npoints: 10);
    var convertedResultFirst2 = resultFirst2.geometry?.coordinates.map((pos) =>
    [double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)), double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))]).toList();
    expect(convertedResultFirst2, resultsFirstTest2);
  });
  
  // Second test - intermediate coordiantes (non-straight lines)
  final start2 = Position(48, -122);
  final end2 = Position(39, -77);

  List<List<double>> resultsSecondTest1 = [[48.0, -122.0], [45.75, -97.73], [39.0, -77.0]];
  List<List<double>> resultsSecondTest2 = [[48.0, -122.0], [47.52, -109.61], [45.75, -97.73], [42.85, -86.80], [39.0, -77.0]];


  test('Great circle intermediate tests:', () {

    var resultSecond1 = greatCircle(start2, end2, npoints: 2);
    var convertedResultSecond1 = resultSecond1.geometry?.coordinates.map((pos) =>
    [double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)), double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))]).toList();
    expect(convertedResultSecond1, resultsSecondTest1);

    var resultSecond2 = greatCircle(start2, end2, npoints: 4);
    print(resultSecond2.geometry?.coordinates);
    var convertedResultSecond2 = resultSecond2.geometry?.coordinates.map((pos) =>
    [double.parse((pos[0]).toStringAsFixed(2)), double.parse((pos[1]).toStringAsFixed(2))]).toList();

    print(convertedResultSecond2);
    expect(convertedResultSecond2, resultsSecondTest2);
  });

  // Third test - complex coordinates (crossing anti-meridian)

  final start3 = Position(-21, 143);
  final end3 = Position(41, -140);

  List<List<double>> resultsThirdTest1 = [[-21.0, 143.0], [12.65, 176.68], [41, -140]];
  List<List<double>> resultsThirdTest2 = [[-21.0, 143.0], [-4.36, 160.22], [12.65, 176.68], [28.52, -164.56], [41, -140]];
  test('Great circle complex tests:', () {

    var resultThird1 = greatCircle(start3, end3, npoints: 2);
    var convertedResultThird1 = resultThird1.geometry?.coordinates.map((pos) =>
    [double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)), double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))]).toList();
    expect(convertedResultThird1, resultsThirdTest1);

    var resultThird2 = greatCircle(start3, end3, npoints: 5);
    var convertedResultThird2 = resultThird2.geometry?.coordinates.map((pos) =>
    [double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)), double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))]).toList();
    expect(convertedResultThird2, resultsThirdTest2);
  });
}

