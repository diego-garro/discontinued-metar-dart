import 'package:path/path.dart' show dirname;
import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';
import 'package:simple_logger/simple_logger.dart';

import 'package:metar/src/metar/stations.dart';
import 'package:metar/src/metar/reg_exp.dart';
import 'package:metar/src/units/angle.dart';
import 'package:metar/src/units/length.dart';
import 'package:metar/src/units/pressure.dart';
import 'package:metar/src/units/speed.dart';
import 'package:metar/src/units/temperature.dart';

Future<Station> _getStationFromFile(String stationCode) async {
  var dirName = Platform.script.resolve('../lib/src/metar/stations.csv');
  var myFile = File.fromUri(dirName);
  var text =
      await myFile.openRead().transform(utf8.decoder).transform(LineSplitter());
  var linesList = await text.toList();
  List<String> stationAttributes;
  for (var line in linesList) {
    stationAttributes = line.split(',');
    if (stationAttributes[1] == stationCode) {
      print('From the function: $stationCode');
      print(line);
      print('stationattributes: $stationAttributes');
      break;
    }
  }

  return Station(
    stationAttributes[0].trim(),
    stationAttributes[1],
    stationAttributes[2],
    stationAttributes[3],
    stationAttributes[4],
    stationAttributes[5],
    stationAttributes[6],
    stationAttributes[7],
  );
}

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
  final logger = SimpleLogger();
  String _code;
  List<String> _codeList;
  String _type = 'METAR';
  bool _correction = false;
  String _mode = 'AUTO';
  String _stationID;
  Station _station;
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
  String errorMessage;
  Map<String, dynamic> metarMap;
  final regex = METAR_REGEX();
  List<List> _handlers;

  Metar(String metarcode, {int utcMonth, int utcYear}) {
    logger.setLevel(Level.INFO);

    if (metarcode == '' || metarcode == null) {
      errorMessage = 'metarcode must be not null or empty string.';
      logger.info(errorMessage);
      throw ParserError(errorMessage);
    }

    _code =
        metarcode.trim().replaceAll(RegExp(r'\s+'), ' ').replaceAll('=', '');
    _codeList = _code.split(' ');

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

    _createHandlersListAndParse();
  }

  // Handlers for groups
  void _handleType(String group) {
    /*
    Parse the report type group

    The following attributes are set
      _type    [String]
    */
    _type = group;
  }

  void _handleStation(String group) async {
    /*
    Parse the station id group

    The following attributes are set
      _stationID [String]   
      _station   [Station]
    */
    _stationID = group;
    _station = await _getStationFromFile(_stationID);
    print(_station);
    print('Nombre de la estación: ${_station.name}');
    print('Posición: ${_station.longitude.inRadians}');
  }

  void _handleCorrection(String group) {
    /*
    Parse the correction group.

    The following attributes are set
      _correction   [bool]
    */
    if (group != null) {
      _correction = true;
    }
  }

  void _handleTime(String group) {
    /*
    Parse the observation-time group.

    The following attributes are set:
      _time    [DateTime]
      day      [int]
      hour     [int]
      min      [int]
    */
    final day = int.parse(group.substring(0, 2));
    final hour = int.parse(group.substring(2, 4));
    final min = int.parse(group.substring(4, 6));

    _time = DateTime(_year, _month, day, hour, min);
  }

  void _createHandlersListAndParse() {
    _handlers = [
      [regex.TYPE_RE, _handleType, false],
      [regex.STATION_RE, _handleStation, false],
      [regex.TIME_RE, _handleTime, false],
      [regex.COR_RE, _handleCorrection, false],
    ];

    _codeList.forEach((group) {
      for (var handler in _handlers) {
        logger.info('${group}, MATCH: ${handler[0].hasMatch(group)}');
        print(handler[0].stringMatch(group));
        if (handler[0].hasMatch(group) && !handler[2]) {
          handler[1](group);
          handler[2] = true;
          break;
        }
        // if (_handlers.indexOf(handler) == _handlers.length - 1) {
        //   errorMessage = 'failed while processing "$group". Code: $_code.';
        //   logger.info(errorMessage);
        //   throw ParserError(errorMessage);
        // }
      }
    });
  }

  // Getters
  int get month => _month;
  int get year => _year;
  String get code => _code;
  List<String> get codeList => _codeList;
  String get type => _type;
  DateTime get time => _time;
  bool get correction => _correction;
  String get stationID => _stationID;
  Station get station => _station;
}
