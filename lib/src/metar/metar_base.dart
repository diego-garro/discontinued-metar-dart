import 'package:path/path.dart' show dirname;
import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';
import 'package:simple_logger/simple_logger.dart';

import 'package:metar/src/units/direction.dart';
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
  var linesList = await myFile
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .toList();
  List<String> stationAttributes;
  for (var line in linesList) {
    stationAttributes = line.split(',');
    if (stationAttributes[1] == stationCode) {
      // print('From the function: $stationCode');
      // print(line);
      // print('stationattributes: $stationAttributes');
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

String _handleLowHighRunway(String range) {
  range ??= range = '';

  if (range.contains('P')) {
    return 'greater than';
  } else if (range.contains('M')) {
    return 'less than';
  } else {
    return '';
  }
}

Length _handleRunwayRange(String range, String units) {
  range ??= range = '0.0';
  var value = range
      .replaceFirst(RegExp(r'^(M|P)?'), '')
      .replaceFirst('FT', '')
      .replaceFirst(RegExp(r'(N|U|D)?$'), '');
  if (units == 'feet') {
    return Length.fromFeet(value: double.tryParse(value));
  } else {
    return Length.fromMeters(value: double.tryParse(value));
  }
}

Temperature _defineTemperature(String sign, String temp) {
  if (sign != null) {
    return Temperature.fromCelsius(value: double.parse('-' + temp));
  }
  return Temperature.fromCelsius(value: double.parse(temp));
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
  String _mod = 'AUTO';
  String _stationID;
  Future<Station> _station;
  DateTime _time;
  int _cycle;
  Direction _windDir;
  Speed _windSpeed;
  Speed _windGust;
  Direction _windDirFrom;
  Direction _windDirTo;
  Length _vis;
  Length _optionalVis;
  Length _maxVis;
  Direction _maxVisDir;
  bool _cavok;
  Temperature _temp;
  Temperature _dewpt;
  Pressure _press;
  final _runway =
      <Tuple7<String, String, String, Length, String, Length, String>>[];
  final _weather = <Tuple5<String, String, String, String, String>>[];
  final _sky = <Tuple3<String, Length, String>>[];
  List<Tuple5> _recent;
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
  void _handleType(String group, {RegExpMatch match}) {
    /*
    Parse the report type group

    The following attributes are set
      _type    [String]
    */
    _type = group;
  }

  void _handleStation(String group, {RegExpMatch match}) {
    /*
    Parse the station id group

    The following attributes are set
      _stationID [String]   
      _station   [Station]
    */
    _stationID = group;
    _station = _getStationFromFile(_stationID);
    // print(_station);
    // print('Nombre de la estación: ${_station.name}');
    // print('Posición: ${_station.longitude.inRadians}');
  }

  void _handleCorrection(String group, {RegExpMatch match}) {
    /*
    Parse the correction group.

    The following attributes are set
      _correction   [bool]
    */
    if (group != null) {
      _correction = true;
    }
  }

  void _handleTime(String group, {RegExpMatch match}) {
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

  void _handleModifier(String group, {RegExpMatch match}) {
    /*
    Parse the report-modifier group

    The following attributes are set
      _mod     [String]
    */
    if (group == 'CORR') {
      _mod = 'COR';
    } else if (group == 'NIL' || group == 'FINO') {
      _mod = 'NO DATA';
    } else {
      _mod = group;
    }
  }

  void _handleWind(String group, {RegExpMatch match}) {
    /*
    Parse the wind group

    The following attributes are set
      _windDir     [Direction]
      _windSpeed   [Speed]
      _windGust    [Speed]
    */
    group.replaceAll('O', '0');
    String units, windDir, windSpeed, windGust;

    units = match.namedGroup('units');
    windDir = match.namedGroup('dir');
    windSpeed = match.namedGroup('speed');
    windGust = match.namedGroup('gust');

    if (windDir != null && RegExp(r'^\d+$').hasMatch(windDir)) {
      _windDir = Direction.fromDegrees(value: windDir);
    } else {
      _windDir = Direction.fromUndefined(value: windDir);
    }
    if (windSpeed != null && RegExp(r'^\d+$').hasMatch(windSpeed)) {
      if (units == 'KT' || units == 'KTS') {
        _windSpeed = Speed.fromKnot(value: double.parse(windSpeed));
      } else {
        _windSpeed = Speed.fromMeterPerSecond(value: double.parse(windSpeed));
      }
    }
    if (windGust != null && group.contains('G')) {
      _windGust = Speed.fromKnot(value: double.parse(windGust));
    }
  }

  void _handleWindVariation(String group, {RegExpMatch match}) {
    /*
    Parse the wind variation

    The following attributes are set
      _windDirFrom    [Direction]
      _windDirTo      [Direction]
    */
    _windDirFrom = Direction.fromDegrees(value: match.namedGroup('from'));
    _windDirTo = Direction.fromDegrees(value: match.namedGroup('to'));
  }

  void _handleOptionalVisibility(String group, {RegExpMatch match}) {
    /*
    Parse the optional visibility if units are SM

    The following attributes are set
      _optionalVisibility   [Length]
    */
    _optionalVis = Length.fromMiles(value: double.parse(group));
  }

  void _handleVisibility(String group, {RegExpMatch match}) {
    /*
    Parse the visibility group

    The following attributes are set
      _vis    [Length]
    */
    String units, vis, extreme, visExtreme, cavok;
    units = match.namedGroup('units');
    vis = match.namedGroup('vis');
    extreme = match.namedGroup('extreme');
    visExtreme = match.namedGroup('visextreme');
    cavok = match.namedGroup('cavok');

    if (visExtreme != null && visExtreme.contains('/')) {
      var items = visExtreme.split('/');
      vis = '${int.parse(items[0]) / int.parse(items[1])}';
    }

    (cavok == null) ? _cavok = false : _cavok = true;

    units ??= units = 'M';

    if (units == 'SM') {
      if (_optionalVis != null) {
        _vis =
            Length.fromMiles(value: _optionalVis.inMiles + double.parse(vis));
      } else {
        _vis = Length.fromMiles(value: double.parse(vis));
      }
    } else if (units == 'KM') {
      _vis = Length.fromKilometers(value: double.parse(vis));
    } else {
      if (vis == '9999' || _cavok) {
        _vis = Length.fromMeters(value: double.parse('10000'));
      } else {
        _vis = Length.fromMeters(value: double.parse(vis));
      }
    }
  }

  void _handleMaxVis(String group, {RegExpMatch match}) {
    /*
    Parse the max vis group

    The following attributes are set
      _maxVis     [Length]
      _maxVisDir  [Direction]
    */
    _maxVis = Length.fromMeters(value: double.parse(match.namedGroup('vis')));
    _maxVisDir = Direction.fromUndefined(value: match.namedGroup('dir'));
  }

  void _handleRunway(String group, {RegExpMatch match}) {
    /*
    Parse the runway visual range group

    The following attributes are set
      _runway         [List<Tuple7>]
        * name        [String]
        * rangeUnits  [String]
        * low         [String]
        * lowRange    [Length]
        * high        [String]
        * highRange   [Length]
        * trend       [String]
    */

    Tuple7<String, String, String, Length, String, Length, String> runway;
    String name, units, low, high, trend;

    name = match.namedGroup('name');
    units = match.namedGroup('units');
    low = match.namedGroup('low');
    high = match.namedGroup('high');
    trend = match.namedGroup('trend');

    // adding the runway name
    var runwayName = name
        .substring(1)
        .replaceFirst('L', ' left')
        .replaceFirst('R', ' right')
        .replaceFirst('C', ' center');

    // adding the range units
    units ??= units = 'M';
    if (units == 'FT') {
      units = 'feet';
    } else {
      units = 'meters';
    }

    // adding if the low range is out of medition
    low = _handleLowHighRunway(low);
    // adding the low range
    var lowRange = _handleRunwayRange(low, units);

    // adding if the high range is out of medition
    high = _handleLowHighRunway(high);
    // adding the high range
    var highRange = _handleRunwayRange(high, units);

    // adding the trend
    trend ??= trend = '';
    if (trend.contains('N')) {
      trend = 'no change';
    } else if (trend.contains('U')) {
      trend = 'increasing';
    } else {
      trend = 'decreasing';
    }

    runway = Tuple7(name, units, low, lowRange, high, highRange, trend);
    _runway.add(runway);
  }

  void _handleWeather(String group, {RegExpMatch match}) {
    /*
    Parse the weather groups

    The following attributes are set
      _weather          [List<Tuple5>]
        * intensity     [String]
        * description   [String]
        * precipitation [String]
        * obscuration   [String]
        * other         [String]
    */

    Tuple5<String, String, String, String, String> tuple;
    String intensity, description, precipitation, obscuration, other;

    intensity = match.namedGroup('intensity');
    description = match.namedGroup('descrip');
    precipitation = match.namedGroup('precip');
    obscuration = match.namedGroup('obsc');
    other = match.namedGroup('other');

    tuple = Tuple5(intensity, description, precipitation, obscuration, other);
    _weather.add(tuple);
  }

  void _handleSky(String group, {RegExpMatch match}) {
    /*
    Parse the sky groups

    The following attributes are set
      _sky        [List<Tuple3>]
        * cover   [String]
        * height  [Length]
        * cloud   [String]
    */
    Tuple3<String, Length, String> sky;
    String cover, height, cloud;
    Length heightVis;

    cover = match.namedGroup('cover');
    height = match.namedGroup('height');
    cloud = match.namedGroup('cloud');

    if (height == '///' || height == null) {
      heightVis = Length.fromFeet();
    } else {
      heightVis = Length.fromFeet(value: double.parse(height) * 100);
    }

    sky = Tuple3(cover, heightVis, cloud);
    _sky.add(sky);
  }

  void _handleTemperatures(String group, {RegExpMatch match}) {
    /*
    Parse the temperature group

    The following attributes are set
      _temp   [Temperature]
      _dewpt  [Temperature]
    */
    String tsign, temp, dsign, dewpt;
    var regex = RegExp(r'^\d{2}');

    tsign = match.namedGroup('tsign');
    temp = match.namedGroup('temp');
    dsign = match.namedGroup('dsign');
    dewpt = match.namedGroup('dewpt');

    if (regex.hasMatch(temp)) {
      _temp = _defineTemperature(tsign, temp);
    }

    if (regex.hasMatch(dewpt)) {
      _dewpt = _defineTemperature(dsign, dewpt);
    }
  }

  void _createHandlersListAndParse() {
    _handlers = [
      [regex.TYPE_RE, _handleType, false],
      [regex.STATION_RE, _handleStation, false],
      [regex.TIME_RE, _handleTime, false],
      [regex.COR_RE, _handleCorrection, false],
      [regex.MODIFIER_RE, _handleModifier, false],
      [regex.WIND_RE, _handleWind, false],
      [regex.WINDVARIATION_RE, _handleWindVariation, false],
      [regex.OPTIONALVIS_RE, _handleOptionalVisibility, false],
      [regex.VISIBILITY_RE, _handleVisibility, false],
      [regex.SECVISIBILITY_RE, _handleMaxVis, false],
      [regex.RUNWAY_RE, _handleRunway, false],
      [regex.WEATHER_RE, _handleWeather, false],
      [regex.WEATHER_RE, _handleWeather, false],
      [regex.WEATHER_RE, _handleWeather, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.TEMP_RE, _handleTemperatures, false],
    ];
    Iterable<RegExpMatch> matches;

    _codeList.forEach((group) {
      for (var handler in _handlers) {
        logger.info('${group}, MATCH: ${handler[0].hasMatch(group)}');
        print(handler[0].stringMatch(group));
        if (handler[0].hasMatch(group) && !handler[2]) {
          matches = handler[0].allMatches(group);
          handler[1](group, match: matches.elementAt(0));
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
  Future<Station> get station async => await _station;
  String get modifier => _mod;
  Direction get windDir => _windDir;
  Speed get windSpeed => _windSpeed;
  Speed get windGust => _windGust;
  Direction get windDirFrom => _windDirFrom;
  Direction get windDirTo => _windDirTo;
  Length get visibility => _vis;
  Length get maxVisibility => _maxVis;
  Direction get maxVisibilityDirection => _maxVisDir;
  List get runway => _runway;
  List<Tuple5> get weather => _weather;
  List<Tuple3> get sky => _sky;
  Temperature get temperature => _temp;
  Temperature get dewPointTemperature => _dewpt;
}
