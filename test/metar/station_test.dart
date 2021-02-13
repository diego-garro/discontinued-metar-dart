import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() {
  final code =
      'KJFK 122051Z 32004KT 10SM OVC065 M02/M15 A3031 RMK AO2 SLP264 T10171150 56004';
  final metar = Metar(code);
  group('String', () {
    test('Test the name of station', () {
      var value = metar.station.name;
      expect(value, 'NY NYC/JFK ARPT');
    });

    test('Test the IATA code of station', () {
      var value = metar.station.iata;
      expect(value, 'JFK');
    });

    test('Test the SYNOP code of station', () {
      var value = metar.station.synop;
      expect(value, '74486');
    });

    test('Test the country of station', () {
      var value = metar.station.country;
      expect(value, 'United States of America (the)');
    });
  });

  group('double', () {
    test('Test the latitude of station', () {
      var value = metar.station.latitude.inDegrees;
      expect(value, 40.38);
    });

    test('Test the longitude of station', () {
      var value = metar.station.longitude.inDegrees;
      expect(value, -73.46);
    });
  });

  test('Test the elevation of station', () {
    var value = metar.station.elevation;
    expect(value, 9);
  });
}
