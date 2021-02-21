import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() {
  group('double', () {
    final code =
        'CYPR 210003Z AUTO 15015G25KT 3SM -RA BR OVC021 04/03 A2956 RMK SLP017';
    final metar = Metar(code);

    test('Test the absolute temperature of METAR', () {
      var value = metar.temperature.inCelsius;
      expect(value, 4.0);
    });

    test('Test the dewpoint temperature of METAR', () {
      var value = metar.dewPointTemperature.inCelsius;
      expect(value, 3.0);
    });
  });
}
