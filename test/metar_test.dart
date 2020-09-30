// import 'package:path/path.dart' show dirname;
// import 'dart:io';
// import 'dart:convert';

import 'package:metar/metar.dart';
import 'package:metar/src/units/position.dart';

class MiError implements Exception {
  String cause;
  MiError(this.cause);
}

void main() {
  var code =
      'METAR MROC 071200Z   10018KT    3000 R07/P2000N BR VV003 17/09 A2994 RESHRA NOSIG=';

  var metar = Metar(code, utcYear: 2021, utcMonth: 10);
  print('Month: ${metar.month}, Year: ${metar.year}');
  print(metar.code);
  // final pos1 = Position(56.0, 75.0);
  // final pos2 = Position(20.5, 105.4);

  // print(pos1);
  // print(pos2);
  // print(pos1.getDistanceFrom(pos2).inKilometers);
  // print(pos1.getDirectionFrom(pos2).inDegrees);
  // try {
  //   throw MiError('Un error ocurrió :(');
  // } catch (e) {
  //   print('se levantó mi excepción: ${e.cause}');
  // }
  // var dirName = Platform.script.path;
  // var myFile = File(dirname(dirName) + '/data.txt');

  // myFile.readAsString().then((String contents) {
  //   print(contents);
  // });

  // myFile.openRead().transform(utf8.decoder).forEach((line) {
  //   print('line: $line');
  // });
}
