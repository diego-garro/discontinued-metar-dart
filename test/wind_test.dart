import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() {
  test('Returns the wind speed of the report', () {
    var code = 'MROC 290400Z 08018G31KT CAVOK 22/15 A2999 NOSIG';
    var metar = Metar(code);
    var value = metar.windSpeed.inKnot;
    expect(value, 18.0);
  });
}
