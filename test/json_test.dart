import 'package:metar/metar.dart';

void main() async {
  var metarcode =
      'NFNM 122100Z 13025G35KT 7000 300NW R07L/0500D R25R/P1000D R18C/M1500N 270V100 +RA BR VCTS FEW010 SCT025TCU BKN100 OVC250 28/27 A3002 RERA BECMG 25005KT 4000 RA BR VV/// RMK VIS SW 5KM RASH N NW';
  // var metarcode = 'MROC 282200Z 08021G35KT 9999 FEW025 24/15 A2994 NOSIG';
  // var metarcode =
  //     'KMIA 281114Z 27008KT 8SM BKN013 OVC038 22/21 A3008 RMK AO2 T02220206';
  // var metarcode =
  //     'MRLB 282000Z COR 09027G38KT 180V070 CAVOK 32/16 A2980 WS R09 NOSIG';

  var metar = Metar(metarcode);
  print('METAR runway: ${metar.runway.isEmpty}');
  var metar_json = await metar.toJson();

  print(metar_json);
}
