import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() {
  final code_weather =
      'EISG 201400Z 14015G27KT 100V170 5000 -RA SCT014 BKN019 OVC025 11/10 Q0973 RERA';
  final metar_weather = Metar(code_weather);

  test('Test the suplementary info of METAR', () {
    var value = metar_weather.recentWeather;
    var expected = <String>[null, 'RA', null, null];
    expect(value, expected);
  });

  final code_windshear =
      'KHND 202256Z 34023G28KT 10SM FEW110 15/M11 A3002 WS ALL RWY RMK AO2 PK WND 33031/2242 SLP181 T01501111';
  final metar_windshear = Metar(code_windshear);

  test('Test the windshear of METAR', () {
    var value = metar_windshear.windshear;
    var expected = <String>['WS', 'ALL', 'RWY'];
    expect(value, expected);
  });
}
