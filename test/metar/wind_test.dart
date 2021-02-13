import 'dart:math';

import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() {
  var code = 'MROC 290400Z 08018G31KT 160V080 CAVOK 22/15 A2999 NOSIG';
  var metar = Metar(code);
  group('double', () {
    test('Test the wind direction of the report', () {
      var value = metar.windDir.directionInDegrees;
      expect(value, 80.0);
    });

    test('Test the wind speed of the report', () {
      var value = metar.windSpeed.inKnot;
      expect(value, 18.0);
    });

    test('Test the wind gust of the report', () {
      var value = metar.windGust.inKnot;
      expect(value, 31.0);
    });

    test('Test the wind variation from', () {
      var value = metar.windDirFrom.directionInDegrees;
      expect(value, 160.0);
    });

    test('Test the wind variation to', () {
      var value = metar.windDirTo.directionInDegrees;
      expect(value, 80.0);
    });
  });

  group('String', () {
    test('Test the wind direction cardinal point of the report', () {
      var value = metar.windDir.cardinalPoint;
      expect(value, 'E');
    });

    test('Test the wind variation from cardinal point', () {
      var value = metar.windDirFrom.cardinalPoint;
      expect(value, 'SSE');
    });

    test('Test the wind variation to cardinal point', () {
      var value = metar.windDirTo.cardinalPoint;
      expect(value, 'E');
    });
  });
}
