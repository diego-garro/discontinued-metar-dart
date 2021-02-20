import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'package:metar/metar.dart';

void main() {
  final code =
      'NWWW 190730Z AUTO 35008KT 320V020 4300 +RA BR VCTS FEW029/// BKN043/// OVC052/\/\/ ///CB 26/25 Q1009 TEMPO 2500 TSRA';
  final metar = Metar(code);

  group('String', () {
    test('Test the first weather found', () {
      var value = metar.weather.first;
      var expected = Tuple5<String, String, String, String, String>(
          '+', null, 'RA', null, null);
      expect(value, expected);
    });

    test('Test the second weather found', () {
      var value = metar.weather[1];
      var expected = Tuple5<String, String, String, String, String>(
          null, null, null, 'BR', null);
      expect(value, expected);
    });

    test('Test the second weather found', () {
      var value = metar.weather.last;
      var expected = Tuple5<String, String, String, String, String>(
          'VC', 'TS', null, null, null);
      expect(value, expected);
    });
  });
}
