import 'package:test/test.dart';

import 'package:metar/metar.dart';

void main() async {
  /// Error in group "10018K", must be "10018KT"
  test('ParserError message from bad coded METAR', () {
    final code =
        'METAR MROC 071200Z 10018K 3000 1000SW R07/P2000N BR VV003 17/09 A2994 RESHRA NOSIG';
    expect(() => Metar(code), throwsA(TypeMatcher<ParserError>()));
  });
}
