import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() {
  final code =
      'SCFA 121300Z 21008KT 9999 3000W R07/M0150V0600U TSRA FEW020 20/13 Q1014 NOSIG';
  final metar = Metar(code);

  group('String', () {
    test('Test the direction of secondary visibility', () {
      var value = metar.maxVisibilityDirection.cardinalPoint;
      expect(value, 'W');
    });

    test('Test the name of runway in runway range', () {
      var value = metar.runway[0].item1;
      expect(value, '07');
    });

    test('Test the trend of runway range', () {
      var value = metar.runway[0].item7;
      expect(value, 'increasing');
    });
  });

  group('double', () {
    test('Test the prevailing visibility', () {
      var value = metar.visibility.inMeters;
      expect(value, 10000.0);
    });

    test('Test the secondary visibility', () {
      var value = metar.maxVisibility.inMeters;
      expect(value, 3000.0);
    });

    test('Test the direction of secondary visibility', () {
      var value = metar.maxVisibilityDirection.directionInDegrees;
      expect(value, 270.0);
    });

    test('Test the low runway visibility', () {
      var value = metar.runway[0].item4.inMeters;
      expect(value, 150.0);
    });

    test('Test the high runway visibility', () {
      var value = metar.runway[0].item6.inMeters;
      expect(value, 600.0);
    });
  });
}
