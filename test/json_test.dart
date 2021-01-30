import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() {
  var code = 'MROC 290400Z 08018G31KT CAVOK 22/15 A2999 NOSIG';
  var json =
      '{"code":"MROC 290400Z 08018G31KT CAVOK 22/15 A2999 NOSIG","type":"METAR","time":"2021-01-29 04:00:00.000","station":{"name":"JUAN SANTAMARIA","icao":"MROC","iata":"","synop":"78762","elevation":"920","country":"Costa Rica","latitude":"10.00","longitude":"-084.13"},"wind":{"direction":{"degrees":"80.0","cardinalPoint":"E"},"speed":"18.0","gust":"31.0","variation":{"from":{"degrees":"null","cardinalPoint":"null"},"to":{"degrees":"null","cardinalPoint":"null"}}},"visibility":{"prevailing":"10000.0","minimum":"null","minimumVisDirection":"null","cavok":true,"runway":{"first":null,"second":null,"third":null}},"weather":{"first":null,"second":null,"third":null},"sky":{"first":null,"second":null,"third":null,"fourth":null},"temperatures":{"absolute":"22.0","dewpoint":"15.0"},"pressure":"1015.58","suplementary":{"recentWeather":"null","windshear":{"runway":"null"}},"remark":null,"trend":{"code":"NOSIG","wind":{"direction":{"degrees":"null","cardinalPoint":"null"},"speed":"null","gust":"null"},"weather":{"first":null,"second":null,"third":null},"sky":{"first":null,"second":null,"third":null}}}';

  test('Returns the METAR as a Json format', () async {
    var metar = Metar(code);
    expect(await metar.toJson(), equals(json));
  });
}
