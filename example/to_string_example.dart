import 'package:metar/metar.dart';

void main() async {
  // final metarcode = 'MROC 110500Z 10009KT CAVOK 21/15 A2999 BECMG 25005KT';
  final metarcode =
      'METAR KJFK 071200Z COR 10015G25KT 5000 1500W R07/P2000N BKN005 SCT010CB 17/09 A2994 TEMPO 5000 25005KT RA';
  final metar = Metar(metarcode, utcYear: 2008, utcMonth: 5);

  print(metar);
}
