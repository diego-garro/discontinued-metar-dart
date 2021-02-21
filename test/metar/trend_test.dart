import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'package:metar/metar.dart';

void main() {
  final codeWind =
      'TFFF 201930Z AUTO 10014KT 9999 FEW045 SCT066 28/20 Q1014 TEMPO 10017G28KT';
  var metarWind = Metar(codeWind);

  group('String', () {
    test('Test the trend code of METAR', () {
      var value = metarWind.trendCode;
      expect(value, 'TEMPO');
    });

    test('Test the wind direction of trend', () {
      var value = metarWind.trendWindDir.cardinalPoint;
      expect(value, 'E');
    });
  });

  group('double', () {
    test('Test the wind direction of trend', () {
      var value = metarWind.trendWindDir.directionInDegrees;
      expect(value, 100.0);
    });

    test('Test the wind speed of trend', () {
      var value = metarWind.trendWindSpeed.inKnot;
      expect(value, 17.0);
    });

    test('Test the wind gust of trend', () {
      var value = metarWind.trendWindGust.inKnot;
      expect(value, 28.0);
    });
  });

  var codeOther =
      'TFFF 200830Z AUTO 11012KT 9999 FEW035 24/21 Q1016 TEMPO 4900 -SHRA BKN022TCU';
  var metarOther = Metar(codeOther);

  group('String', () {
    test('Test the cover of cloud layer of trend', () {
      var value = metarOther.trendSky.first.item1;
      expect(value, 'BKN');
    });

    test('Test the cloud type of layer of trend', () {
      var value = metarOther.trendSky.first.item3;
      expect(value, 'TCU');
    });
  });

  group('double', () {
    test('Test the visibility of trend', () {
      var value = metarOther.trendVisibility.inMeters;
      expect(value, 4900.0);
    });

    test('Test the height of cloud layer of trend', () {
      var value = metarOther.trendSky.first.item2.inFeet;
      expect(value, 2200.0);
    });
  });

  test('Test the weather of trend', () {
    var value = metarOther.trendWeather.first;
    var expected = Tuple5('-', 'SH', 'RA', null, null);
    expect(value, expected);
  });
}
