// import 'package:path/path.dart' show dirname;
// import 'dart:io';
// import 'dart:convert';

// var dirName = Platform.script.path;
// var myFile = File(dirname(dirName) + '/stations.csv');
// myFile.readAsString().then((String contents) {
//   print(contents);
// });

// myFile.openRead().transform(utf8.decoder).forEach((line) {
//   print('line: $line');
// });

import 'package:tuple/tuple.dart';

import 'package:metar/src/units/angle.dart';
import 'package:metar/src/units/length.dart';
import 'package:metar/src/units/pressure.dart';
import 'package:metar/src/units/speed.dart';
import 'package:metar/src/units/temperature.dart';

class ParserError implements Exception {
  String _message = 'ParserError: ';

  ParserError(String message) {
    _message += message;
  }

  @override
  String toString() {
    return _message;
  }
}

class Metar {
  String _code;
  String _type = 'METAR';
  String _correction;
  String _mode = 'AUTO';
  String _stationID;
  DateTime _time;
  int _cycle;
  Angle _windDir;
  Speed _windSpeed;
  Speed _windGust;
  Angle _windDirFrom;
  Angle _windDirTo;
  Length _vis;
  Length _maxVis;
  Angle _maxVisDir;
  Temperature _temp;
  Temperature _dewpt;
  Pressure _press;
  List<Tuple4> _runway;
  List<Tuple4> _weather;
  List<Tuple5> _recent;
  List<Tuple3> _sky;
  List<String> _windshear;
  Speed _windSpeedPeak;
  Angle _windDirPeak;
  DateTime _windPeakTime;
  DateTime _windShiftTime;
  Temperature _maxTemp6hr;
  Temperature _minTemp6hr;
  Temperature _maxTemp24hr;
  Temperature _minTemp24hr;
  Pressure _pressSeaLevel;
  double _precip1hr;
  double _precip3hr;
  double _precip6hr;
  double _precip24hr;
  Length _snowDepth;
  double _iceAccretion1hr;
  double _iceAccretion3hr;
  double _iceAccretion6hr;
  bool _trend = false;
  List _trendGroups;
  List<String> _remarks;
  List<String> _unparsedGroups;
  List<String> _unparsedRemarks;
  int _month;
  int _year;
  DateTime _now;

  Metar(String metarcode, {int utcMonth, int utcYear}) {
    if (metarcode == '' || metarcode == null) {
      throw ParserError('metarcode must be not null or empty string.');
    }

    _code =
        metarcode.trim().replaceAll(RegExp(r'\s+'), ' ').replaceFirst('=', '');

    _now = DateTime.now();

    if (utcMonth != null) {
      _month = utcMonth;
    } else {
      _month = _now.month;
    }

    if (utcYear != null) {
      _year = utcYear;
    } else {
      _year = _now.year;
    }
  }

  // Getters
  int get month => _month;
  int get year => _year;
  String get code => _code;
}
