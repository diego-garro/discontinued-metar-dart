import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() {
  test('Returns the METAR as a Json format', () async {
    final code =
        'METAR MROC 071200Z COR 10015G25KT 250V110 0500 R07/P2000N BR VV003 17/09 A2994 RESHRA NOSIG';
    final json =
        '{"code":"METAR MROC 071200Z COR 10015G25KT 250V110 0500 R07/P2000N BR VV003 17/09 A2994 RESHRA NOSIG","type":"METAR","time":"2021-01-07 12:00:00.000","station":{"name":"JUAN SANTAMARIA","icao":"MROC","iata":"null","synop":"78762","elevation":"920","country":"Costa Rica","latitude":"10.00","longitude":"-084.13"},"wind":{"units":{"speed":"knot"},"direction":{"degrees":"100.0","cardinalPoint":"E"},"speed":"15.0","gust":"25.0","variation":{"from":{"degrees":"250.0","cardinalPoint":"WSW"},"to":{"degrees":"110.0","cardinalPoint":"ESE"}}},"visibility":{"units":"meters","prevailing":"500.0","minimum":"null","minimumVisDirection":"null","cavok":false,"runway":{"first":{"name":"07","rangeUnits":"meters","low":"greater than","lowRange":"2000.0","high":"","highRange":"0.0","trend":"no change"},"second":null,"third":null}},"weather":{"first":[null,null,null,"BR",null],"second":null,"third":null},"sky":{"units":{"height":"meters"},"first":{"cover":"VV","height":"91.44","cloud":null},"second":null,"third":null,"fourth":null},"temperatures":{"units":"celcius","absolute":"17.0","dewpoint":"9.0"},"pressure":{"units":"hectoPascal","value":"1013.89"},"suplementary":{"recentWeather":"[SH, RA, null, null]","windshear":{"runway":"null"}},"remark":null,"trend":{"code":"NOSIG","wind":{"units":{"speed":"knot"},"direction":{"degrees":"null","cardinalPoint":"null"},"speed":"null","gust":"null"},"weather":{"first":null,"second":null,"third":null},"sky":{"units":{"height":"meters"},"first":null,"second":null,"third":null}}}';
    final metar = Metar(code);
    expect(await metar.toJson(), equals(json));
  });
}
