import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'package:metar/metar.dart';

void main() {
  final code = 'SBIZ 190700Z 00000KT 9999 FEW005 SCT018CB BKN080 24/24 Q1011';
  final metar = Metar(code);
  group('String', () {
    test('Test the cover of first layer', () {
      var value = metar.sky.first.item1;
      expect(value, 'FEW');
    });

    test('Test the cloud of first layer', () {
      var value = metar.sky.first.item3;
      expect(value, null);
    });

    test('Test the cover of second layer', () {
      var value = metar.sky[1].item1;
      expect(value, 'SCT');
    });

    test('Test the cloud of second layer', () {
      var value = metar.sky[1].item3;
      expect(value, 'CB');
    });

    test('Test the cover of third layer', () {
      var value = metar.sky.last.item1;
      expect(value, 'BKN');
    });

    test('Test the cloud of first layer', () {
      var value = metar.sky.last.item3;
      expect(value, null);
    });
  });

  group('double', () {
    test('Test the height of first layer', () {
      var value = metar.sky.first.item2.inFeet;
      expect(value, 500.0);
    });

    test('Test the height of second layer', () {
      var value = metar.sky[1].item2.inFeet;
      expect(value, 1800.0);
    });

    test('Test the height of third layer', () {
      var value = metar.sky.last.item2.inFeet;
      expect(value, 8000.0);
    });
  });
}
