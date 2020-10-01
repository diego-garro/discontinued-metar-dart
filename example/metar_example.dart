import 'dart:convert';

import '../lib/metar.dart';

void main() {
  var metarcode = 'METAR MROC 071200Z 10018KT 3000 R07/P2000N BR VV003 17/09 A2994 RESHRA NOSIG';
  var metar = Metar(metarcode);

  print(metar.code);
  print(metar.month);
  print(metar.year);
  // String str1 = 'Sara is 26 years old. Maria is 18 while Masood is 8.';

  //Declaring a Rhes sequences of digitsegExp object with a pattern that matc
  // RegExp reg1 = new RegExp(r'(\d+)');

  // Iterable<RegExpMatch> allMatches = reg1.allMatches(str1);
  // print(allMatches);
  // int matchCount = 1;
  // allMatches.forEach((match) {
  //   print('Match $matchCount: ${str1.substring(match.start, match.end)}');
  //   matchCount++;
  // });
  // var awesome = Awesome();
  // print('awesome: ${awesome.isAwesome}');
}
