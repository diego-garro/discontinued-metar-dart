import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() {
  final code =
      'EISG 201630Z 21014G25KT 170V240 9999 FEW016 SCT036 BKN045 09/06 Q0977';
  final metar = Metar(code);

  test('Test the pressure of METAR', () {
    var value = metar.pressure.inInHg;
    expect(value, 28.85);
  });
}
