import 'package:metar/metar.dart';

void main() async {
  final metarcode =
      'METAR MROC 071200Z COR 10015G25KT 250V110 0500 R07/P2000N BR VV003 17/09 A2994 RESHRA NOSIG';
  final metar = Metar(metarcode);

  print(await metar.toJson());
}
