// import 'package:path/path.dart' show dirname;
import 'dart:convert';

import 'package:tuple/tuple.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:http/http.dart' as http;

import 'package:metar/src/units/direction.dart';
import 'package:metar/src/metar/stations.dart';
import 'package:metar/src/metar/reg_exp.dart';
import 'package:metar/src/units/angle.dart';
import 'package:metar/src/units/length.dart';
import 'package:metar/src/units/pressure.dart';
import 'package:metar/src/units/speed.dart';
import 'package:metar/src/units/temperature.dart';

// import 'package:metar/src/database/db_connection.dart';
import 'package:metar/src/utils/capitalize_string.dart';
import 'package:metar/src/metar/translations.dart';
import 'package:metar/src/database/stations.dart';

List<String> _divideMetarCode(String code) {
  String body, rmk, trend;
  final regexp = METAR_REGEX();
  int rmkIndex, trendIndex;
  final logger = SimpleLogger();

  if (regexp.TREND_RE.hasMatch(code)) {
    trendIndex = regexp.TREND_RE.firstMatch(code).start;
  }

  if (regexp.REMARK_RE.hasMatch(code)) {
    rmkIndex = regexp.REMARK_RE.firstMatch(code).start;
  }

  if (trendIndex == null && rmkIndex != null) {
    body = code.substring(0, rmkIndex - 1);
    rmk = code.substring(rmkIndex);
  } else if (trendIndex != null && rmkIndex == null) {
    body = code.substring(0, trendIndex - 1);
    trend = code.substring(trendIndex);
  } else if (trendIndex == null && rmkIndex == null) {
    body = code;
  } else {
    if (trendIndex > rmkIndex) {
      body = code.substring(0, rmkIndex - 1);
      rmk = code.substring(rmkIndex, trendIndex - 1);
      trend = code.substring(trendIndex);
    } else {
      body = code.substring(0, trendIndex - 1);
      trend = code.substring(trendIndex, rmkIndex - 1);
      rmk = code.substring(rmkIndex);
    }
  }
  // logger.info('LOGGER INFO: $body, $trend, $rmk');
  return <String>[body, trend, rmk];
}

Station _getStation(String stationICAO) {
  final result = getStation(stationICAO);

  return Station(
    result[0],
    result[1],
    result[2],
    result[3],
    result[4],
    result[5],
    result[6],
    result[7],
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
    return Length.fromMeters(value: double.parse(value));
  }
}

Temperature _defineTemperature(String sign, String temp) {
  if (sign != null) {
    return Temperature.fromCelsius(value: double.parse('-' + temp));
  }
  return Temperature.fromCelsius(value: double.parse(temp));
}

String _handleRunwayName(String name) {
  return name
      .substring(1)
      .replaceFirst('L', ' left')
      .replaceFirst('R', ' right')
      .replaceFirst('C', ' center');
}

class ParserError implements Exception {
  String _message = 'ParserError: ';

  ParserError(String message) {
    _message += message;
  }

  String get message => _message;

  @override
  String toString() {
    return _message;
  }
}

class Metar {
  final logger = SimpleLogger();
  String _code, _body, _trend, _rmk;
  List<String> _bodyList, _trendList, _rmkList;
  String _type = 'METAR';
  bool _correction = false;
  String _mod = 'AUTO';
  String _stationID;
  Station _station;
  DateTime _time;
  int _cycle;
  Direction _windDir;
  Speed _windSpeed;
  Speed _windGust;
  Direction _trendWindDir;
  Speed _trendWindSpeed;
  Speed _trendWindGust;
  Direction _windDirFrom;
  Direction _windDirTo;
  Length _vis;
  Length _trendVis;
  Length _optionalVis;
  Length _trendOptionalVis;
  Length _maxVis;
  Direction _maxVisDir;
  bool _cavok;
  Temperature _temp;
  Temperature _dewpt;
  Pressure _press;
  final _runway =
      <Tuple7<String, String, String, Length, String, Length, String>>[];
  final _weather = <Tuple5<String, String, String, String, String>>[];
  final _trendWeather = <Tuple5<String, String, String, String, String>>[];
  final _sky = <Tuple3<String, Length, String>>[];
  final _trendSky = <Tuple3<String, Length, String>>[];
  List<String> _recent;
  final _windshear = <String>[];
  String _trendCode;
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
  List<List> _bodyHandlers;
  List<List> _trendHandlers;
  Map<String, dynamic> _map;
  String _string = '### BODY ###\n';

  Metar(String metarcode, {int utcMonth, int utcYear}) {
    logger.setLevel(Level.INFO);

    if (metarcode == '' || metarcode == null) {
      errorMessage = 'metarcode must be not null or empty string.';
      logger.info(errorMessage);
      throw ParserError(errorMessage);
    }

    _code =
        metarcode.trim().replaceAll(RegExp(r'\s+'), ' ').replaceAll('=', '');
    var dividedCode = _divideMetarCode(_code);

    _body = dividedCode[0];
    _trend = dividedCode[1];
    _rmk = dividedCode[2]?.replaceAll(RegExp(r'RMK\s|\sRMK|\sRMK\s'), '');

    _bodyList = _body.split(' ');
    if (_trend != null) {
      _trendList = _trend.split(' ');
    }
    if (_rmk != null) {
      _rmkList = _rmk.split(' ');
    }

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

    _createBodyHandlersListAndParse();
    _createTrendHanldersListAndParse();
  }

  static Future<Metar> mostRecentFromNOAA(String icaoStationCode) async {
    final url =
        'http://tgftp.nws.noaa.gov/data/observations/metar/stations/${icaoStationCode.toUpperCase()}.TXT';

    final response = await http.get(url);
    final data = response.body.split('\n');

    final dateString = data[0].replaceAll('/', '-') + ':00';
    final date = DateTime.parse(dateString);

    return Metar(data[1], utcMonth: date.month, utcYear: date.year);
  }

  Map<String, String> _runwayAsMap(int runwayIndex) {
    return {
      'name': _runway[runwayIndex].item1,
      'rangeUnits': _runway[runwayIndex].item2,
      'low': _runway[runwayIndex].item3,
      'lowRange': '${_runway[runwayIndex].item4?.inMeters}',
      'high': _runway[runwayIndex].item5,
      'highRange': '${_runway[runwayIndex].item6?.inMeters}',
      'trend': _runway[runwayIndex].item7
    };
  }

  /// Returns the sky as a Map<String, String>
  /// params:
  ///   - layer [int] the index of a layer if present
  ///   - section [String] the sky codes to returns
  ///     - options: 'body', 'trend'
  Map<String, String> _skyAsMap(int layer, {String section = 'body'}) {
    if (section == 'body') {
      return {
        'cover': _sky[layer].item1,
        'height': '${_sky[layer].item2?.inMeters}',
        'cloud': _sky[layer].item3,
      };
    } else {
      return {
        'cover': _trendSky[layer].item1,
        'height': '${_trendSky[layer].item2?.inMeters}',
        'cloud': _trendSky[layer].item3,
      };
    }
  }

  /// Returns the runways with windshear reported is present
  String _windshearRunway() {
    if (_windshear.isNotEmpty) {
      if (_windshear.length == 2) {
        return _windshear[1];
      } else {
        return _windshear[2];
      }
    }
    return null;
  }

  /// Returns the metar as a json
  String toJson() {
    _map = <String, dynamic>{
      'code': _code,
      'type': _type,
      'time': _time.toString(),
      'station': _station.toMap(),
      'wind': <String, dynamic>{
        'units': {
          'speed': 'knot',
        },
        'direction': {
          'degrees': '${_windDir?.directionInDegrees}',
          'cardinalPoint': '${_windDir?.cardinalPoint}'
        },
        'speed': '${_windSpeed?.inKnot}',
        'gust': '${_windGust?.inKnot}',
        'variation': {
          'from': {
            'degrees': '${_windDirFrom?.directionInDegrees}',
            'cardinalPoint': '${_windDirFrom?.cardinalPoint}'
          },
          'to': {
            'degrees': '${_windDirTo?.directionInDegrees}',
            'cardinalPoint': '${_windDirTo?.cardinalPoint}'
          },
        },
      },
      'visibility': <String, dynamic>{
        'units': 'meters',
        'prevailing': '${_vis?.inMeters}',
        'minimum': '${_maxVis?.inMeters}',
        'minimumVisDirection': '${_maxVisDir?.cardinalPoint}',
        'cavok': _cavok,
        'runway': <String, Map<String, String>>{
          'first': _runway.isNotEmpty ? _runwayAsMap(0) : null,
          'second': _runway.length > 1 ? _runwayAsMap(1) : null,
          'third': _runway.length > 2 ? _runwayAsMap(2) : null,
        }
      },
      'weather': <String, List>{
        'first': _weather.isNotEmpty ? _weather[0].toList() : null,
        'second': _weather.length > 1 ? _weather[1].toList() : null,
        'third': _weather.length > 2 ? _weather[2].toList() : null
      },
      'sky': <String, Map<String, String>>{
        'units': {
          'height': 'meters',
        },
        'first': _sky.isNotEmpty ? _skyAsMap(0) : null,
        'second': _sky.length > 1 ? _skyAsMap(1) : null,
        'third': _sky.length > 2 ? _skyAsMap(2) : null,
        'fourth': _sky.length > 3 ? _skyAsMap(3) : null,
      },
      'temperatures': {
        'units': 'celcius',
        'absolute': '${_temp?.inCelsius}',
        'dewpoint': '${_dewpt?.inCelsius}',
      },
      'pressure': {'units': 'hectoPascal', 'value': '${_press?.inHPa}'},
      'suplementary': <String, dynamic>{
        'recentWeather': '$_recent',
        'windshear': <String, String>{
          'runway': '${_windshearRunway()}',
        },
      },
      'remark': _rmk,
      'trend': <String, dynamic>{
        'code': _trendCode,
        'wind': <String, dynamic>{
          'units': {
            'speed': 'knot',
          },
          'direction': {
            'degrees': '${_trendWindDir?.directionInDegrees}',
            'cardinalPoint': '${_trendWindDir?.cardinalPoint}',
          },
          'speed': '${_trendWindSpeed?.inKnot}',
          'gust': '${_trendWindGust?.inKnot}',
        },
        'weather': <String, List>{
          'first': _trendWeather.isNotEmpty ? _trendWeather[0].toList() : null,
          'second': _trendWeather.length > 1 ? _trendWeather[1].toList() : null,
          'third': _trendWeather.length > 2 ? _trendWeather[2].toList() : null,
        },
        'sky': <String, Map<String, String>>{
          'units': {
            'height': 'meters',
          },
          'first': _trendSky.isNotEmpty ? _skyAsMap(0, section: 'trend') : null,
          'second':
              _trendSky.length > 1 ? _skyAsMap(1, section: 'trend') : null,
          'third': _trendSky.length > 2 ? _skyAsMap(2, section: 'trend') : null,
        }
      }
    };

    return jsonEncode(_map);
  }

  @override
  String toString() {
    return _string;
  }

  // Handlers for groups
  void _handleType(String group, {RegExpMatch match}) {
    /*
    Parse the report type group

    The following attributes are set
      _type    [String]
    */
    _type = group;
    _string += '--- Type ---\n'
        ' * ${_type}\n';
  }

  void _handleStation(String group, {RegExpMatch match}) {
    /*
    Parse the station id group

    The following attributes are set
      _stationID [String]
      _station   [Station]
    */
    _stationID = group;
    _station = _getStation(_stationID);
    final stationMap = _station.toMap();
    _string += '--- Station ---\n'
        ' * Name: ${stationMap['name']}\n'
        ' * ICAO: ${stationMap['icao']}\n'
        ' * IATA: ${stationMap['iata']}\n'
        ' * SYNOP: ${stationMap['synop']}\n'
        ' * Longitude: ${stationMap['longitude']}\n'
        ' * Latitude: ${stationMap['latitude']}\n'
        ' * Elevation: ${stationMap['elevation']}\n'
        ' * Country: ${stationMap['country']}\n';
  }

  void _handleCorrection(String group, {RegExpMatch match}) {
    /*
    Parse the correction group.

    The following attributes are set
      _correction   [bool]
    */
    if (group != null) {
      _correction = true;
      _string += '--- Correction ---\n';
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
    _string += '--- Time ---\n'
        ' * ${_time}\n';
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

  void _handleWind(
    String group, {
    RegExpMatch match,
    String section = 'body',
  }) {
    /*
    Parse the wind group

    params:
      group:    [String] The individual group
      match:    [RegExpMatch] The matcha of the regular expression
      section:  [String] Section of Metar that will be parsed
        options -> body
                -> trend

    The following attributes are set
      _windDir/_trendWindDir      [Direction]
      _windSpeed/_trendWindSpeed  [Speed]
      _windGust/_trendWindGust    [Speed]
    */
    group.replaceAll('O', '0');
    String units, windDir, windSpeed, windGust;
    Direction dirValue;
    Speed speedValue, gustValue;

    units = match.namedGroup('units');
    windDir = match.namedGroup('dir');
    windSpeed = match.namedGroup('speed');
    windGust = match.namedGroup('gust');

    if (windDir != null && RegExp(r'^\d+$').hasMatch(windDir)) {
      dirValue = Direction.fromDegrees(value: windDir);
    } else {
      dirValue = Direction.fromDegrees(value: windDir);
    }
    if (windSpeed != null && RegExp(r'^\d+$').hasMatch(windSpeed)) {
      if ((units == 'KT' || units == 'KTS')) {
        speedValue = Speed.fromKnot(value: double.parse(windSpeed));
      } else {
        speedValue = Speed.fromKnot(value: double.parse(windSpeed));
      }
    }
    if (windGust != null && group.contains('G')) {
      gustValue = Speed.fromKnot(value: double.parse(windGust));
    }

    void stringHelper(Direction dir, Speed speed, Speed gust) {
      _string += '--- Wind ---\n'
          ' * Direction:\n'
          '   - Degrees: ${dir.variable == 'not variable' ? dir.directionInDegrees : 'Variable'}\n'
          '   - Cardinal point: ${dir.variable == 'not variable' ? dir.cardinalPoint : 'Variable'}\n'
          ' * Speed: ${speed.inKnot} knots\n'
          ' * Gust: ${gust != null ? gust.inKnot : 0.0} knots\n';
    }

    if (section == 'body') {
      _windDir = dirValue;
      _windSpeed = speedValue;
      _windGust = gustValue;
      stringHelper(_windDir, _windSpeed, _windGust);
    } else {
      _trendWindDir = dirValue;
      _trendWindSpeed = speedValue;
      _trendWindGust = gustValue;
      stringHelper(_trendWindDir, _trendWindSpeed, _trendWindGust);
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
    _string += ' * Variation:\n'
        '   - From:\n'
        '     > Degrees: ${_windDirFrom.directionInDegrees}\n'
        '     > Cardinal point: ${_windDirFrom.cardinalPoint}\n'
        '   - To:\n'
        '     > Degrees: ${_windDirTo.directionInDegrees}\n'
        '     > Cardinal point: ${_windDirTo.cardinalPoint}\n';
  }

  void _handleOptionalVisibility(
    String group, {
    RegExpMatch match,
    String section = 'body',
  }) {
    /*
    Parse the optional visibility if units are SM

    params:
      group:    [String] The individual group
      match:    [RegExpMatch] The matcha of the regular expression
      section:  [String] Section of Metar that will be parsed
        options -> body
                -> trend

    The following attributes are set
      _optionalVis/_trendOptionalVis   [Length]
    */
    if (section == 'body') {
      _optionalVis = Length.fromMiles(value: double.parse(group));
    } else {
      _trendOptionalVis = Length.fromMiles(value: double.parse(group));
    }
  }

  void _handleVisibility(
    String group, {
    RegExpMatch match,
    String section = 'body',
  }) {
    /*
    Parse the visibility group

    params:
      group:    [String] The individual group
      match:    [RegExpMatch] The matcha of the regular expression
      section:  [String] Section of Metar that will be parsed
        options -> body
                -> trend

    The following attributes are set
      _vis/_trendVis    [Length]
    */
    String units, vis, extreme, visExtreme, cavok;
    Length value;
    units = match.namedGroup('units');
    vis = match.namedGroup('vis');
    extreme = match.namedGroup('extreme');
    visExtreme = match.namedGroup('visextreme');
    cavok = match.namedGroup('cavok');

    if (visExtreme != null && visExtreme.contains('/')) {
      var items = visExtreme.split('/');
      visExtreme = '${int.parse(items[0]) / int.parse(items[1])}';
    }

    if (section == 'body') {
      (cavok == null) ? _cavok = false : _cavok = true;
    }

    units ??= units = 'M';

    if (units == 'SM') {
      if (_optionalVis != null) {
        value = Length.fromMiles(
            value: _optionalVis.inMiles + double.parse(visExtreme));
      } else if (_trendOptionalVis != null) {
        value = Length.fromMiles(
            value: _trendOptionalVis.inMiles + double.parse(visExtreme));
      } else {
        value = Length.fromMiles(value: double.parse(visExtreme));
      }
    } else if (units == 'KM') {
      value = Length.fromKilometers(value: double.parse(visExtreme));
    } else {
      if ((vis == '9999' || _cavok) && section == 'body') {
        value = Length.fromMeters(value: double.parse('10000'));
      } else {
        value = Length.fromMeters(value: double.parse(vis));
      }
    }

    void stringHelper(Length vis) {
      _string += '--- Visibility ---\n'
          ' * Prevailing: ${vis.inMeters} meters\n'
          ' * ${_cavok ? 'CAVOK' : 'No CAVOK'}\n';
    }

    if (section == 'body') {
      _vis = value;
      stringHelper(_vis);
    } else {
      _trendVis = value;
      stringHelper(_trendVis);
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
    _string +=
        ' * Secondary: ${_maxVis.inMeters} meters to ${_maxVisDir.cardinalPoint}\n';
  }

  void _handleRunway(String group, {RegExpMatch match}) {
    /*
    Parse the runway visual range group

    The following attributes are set
      _runway         Tuple7<String, String, String, Length, String, Length, String>
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

    // setting the range units
    units ??= units = 'M';
    if (units == 'FT') {
      units = 'feet';
    } else {
      units = 'meters';
    }

    // setting the low range
    var lowRange = _handleRunwayRange(low, units);

    // setting if the low range is out of medition
    low = _handleLowHighRunway(low);

    // setting the high range
    var highRange = _handleRunwayRange(high, units);

    // setting if the high range is out of medition
    high = _handleLowHighRunway(high);

    // setting the trend
    trend ??= trend = '';
    if (trend.contains('N')) {
      trend = 'no change';
    } else if (trend.contains('U')) {
      trend = 'increasing';
    } else {
      trend = 'decreasing';
    }

    runway = Tuple7(
      _handleRunwayName(name),
      units,
      low,
      lowRange,
      high,
      highRange,
      trend,
    );
    _runway.add(runway);

    if (_runway.last == _runway[0]) {
      _string += ' * Runway:\n';
    }
    _string += '   - Name: ${_runway.last.item1}\n'
        '     > Low range: ${_runway.last.item4.inMeters} meters\n'
        '     > High range: ${_runway.last.item6.inMeters} meters\n';
  }

  void _handleWeather(
    String group, {
    RegExpMatch match,
    String section = 'body',
  }) {
    /*
    Parse the weather groups

    params:
      group:    [String] The individual group
      match:    [RegExpMatch] The matcha of the regular expression
      section:  [String] Section of Metar that will be parsed
        options -> body
                -> trend

    The following attributes are set
      _weather/_trendWeather  [List<Tuple5>]
        * intensity           [String]
        * description         [String]
        * precipitation       [String]
        * obscuration         [String]
        * other               [String]
    */

    Tuple5<String, String, String, String, String> tuple;
    String intensity, description, precipitation, obscuration, other;

    intensity = match.namedGroup('intensity');
    description = match.namedGroup('descrip');
    precipitation = match.namedGroup('precip');
    obscuration = match.namedGroup('obsc');
    other = match.namedGroup('other');

    tuple = Tuple5(intensity, description, precipitation, obscuration, other);

    void stringHelper(Tuple5 weather) {
      final trans = SKY_TRANSLATIONS();

      if ((_weather.isNotEmpty && weather == _weather[0]) ||
          (_trendWeather.isNotEmpty && weather == _trendWeather[0])) {
        _string += '--- Weather ---\n';
      }

      final s = '${weather.item1 != null ? trans.WEATHER_INT[weather.item1] : ''} '
              '${weather.item2 != null ? trans.WEATHER_DESC[weather.item2] : ''} '
              '${weather.item3 != null ? trans.WEATHER_PREC[weather.item3] : ''} '
              '${weather.item4 != null ? trans.WEATHER_OBSC[weather.item4] : ''} '
              '${weather.item5 != null ? trans.WEATHER_OTHER[weather.item5] : ''}'
          .replaceFirst(RegExp(r'\s{2,}'), ' ')
          .trimLeft();

      _string += ' * ' + capitalize(s) + '\n';
    }

    if (section == 'body') {
      _weather.add(tuple);
      stringHelper(_weather.last);
    } else {
      _trendWeather.add(tuple);
      stringHelper(_trendWeather.last);
    }
  }

  void _handleSky(
    String group, {
    RegExpMatch match,
    String section = 'body',
  }) {
    /*
    Parse the sky groups

    params:
      group:    [String] The individual group
      match:    [RegExpMatch] The matcha of the regular expression
      section:  [String] Section of Metar that will be parsed
        options -> body
                -> trend

    The following attributes are set
      _sky/_trendSky        [List<Tuple3>]
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

    void stringHelper(Tuple3 layer) {
      final trans = SKY_TRANSLATIONS();

      if (layer == _sky[0]) {
        _string += '--- Sky ---\n';
      }

      final s = '${trans.SKY_COVER[layer.item1]} at '
              '${layer.item2.inFeet} feet '
              '${layer.item3 != null ? 'of ${trans.CLOUD_TYPE[layer.item3]}' : ''}'
          .replaceFirst(RegExp(r'\s{2,}'), ' ')
          .trimLeft();

      _string += ' * ' + capitalize(s) + '\n';
    }

    if (section == 'body') {
      _sky.add(sky);
      stringHelper(_sky.last);
    } else {
      _trendSky.add(sky);
      stringHelper(_trendSky.last);
    }
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

    _string += '--- Temperatures ---\n'
        ' * Absolute: ${_temp != null ? '${_temp.inCelsius}°C' : 'undefined'}\n'
        ' * Dewpoint: ${_dewpt != null ? '${_dewpt.inCelsius}°C' : 'undefined'}\n';
  }

  void _handlePressure(String group, {RegExpMatch match}) {
    /*
    Parse the pressure group

    The following attributes are set
      _press    [Pressure]
    */
    String units, press, units2;

    units = match.namedGroup('units');
    press = match.namedGroup('press');
    units2 = match.namedGroup('units2');

    if (press != '\//\//') {
      var pressDouble = double.parse(press);
      if (units == 'A' || units2 == 'INS') {
        _press = Pressure.fromInHg(value: pressDouble / 100);
      } else if (units == 'Q' || units == 'QNH') {
        _press = Pressure.fromHPa(value: pressDouble);
      } else if (units == 'SLP') {
        if (pressDouble < 500) {
          pressDouble = pressDouble / 10 + 1000;
        } else {
          pressDouble = pressDouble / 10 + 900;
        }
        _press = Pressure.fromMb(value: pressDouble);
      } else if (pressDouble > 2500.0) {
        _press = Pressure.fromInHg(value: pressDouble / 100);
      } else {
        _press = Pressure.fromMb(value: pressDouble);
      }
    }

    _string += '--- Pressure ---\n'
        ' * ${_press.inHPa} hPa\n';
  }

  void _handleRecent(String group, {RegExpMatch match}) {
    /*
    Parse the recent group

    The following attributes are set
      _recent          [List<Tuple5>]
        * description   [String]
        * precipitation [String]
        * obscuration   [String]
        * other         [String]
    */
    String description, precipitation, obscuration, other;

    description = match.namedGroup('descrip');
    precipitation = match.namedGroup('precip');
    obscuration = match.namedGroup('obsc');
    other = match.namedGroup('other');

    _recent = <String>[description, precipitation, obscuration, other];

    final trans = SKY_TRANSLATIONS();
    final s = '${_recent[0] != null ? trans.WEATHER_DESC[_recent[0]] : ''} '
            '${_recent[1] != null ? trans.WEATHER_PREC[_recent[1]] : ''} '
            '${_recent[2] != null ? trans.WEATHER_OBSC[_recent[2]] : ''} '
            '${_recent[3] != null ? trans.WEATHER_OTHER[_recent[3]] : ''} '
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trimLeft();

    _string += '--- Recent weather ---\n * ' + capitalize(s) + '\n';
  }

  void _handleWindShearPrefix(String group, {RegExpMatch match}) {
    /*
    Parse the windshear group: prefix

    The following attributes are set
      _windshear    [List<String>]
    */
    String prefix;

    prefix = match.namedGroup('prefix');

    _windshear.add(prefix);
  }

  void _handleWindShearRunway(String group, {RegExpMatch match}) {
    /*
    Parse the windshear group: runway

    The following attributes are set
      _windshear    [List<String>]
    */
    String name;

    name = match.namedGroup('runway');

    if (name == 'RWY') {
      _windshear.add(name);
    } else {
      _windshear.add(_handleRunwayName(name));
    }

    _string += '--- Windshear ---\n'
        ' * ${_windshear[1] == 'ALL' ? 'All runways' : 'Runway ${_windshear[1]}'}\n';
  }

  void _parseGroups(
    List<String> groupList,
    List<List> handlers, {
    String section = 'body',
  }) {
    Iterable<RegExpMatch> matches;
    groupList.forEach((group) {
      for (var handler in handlers) {
        if (handler[0].hasMatch(group) && !handler[2]) {
          matches = handler[0].allMatches(group);
          if (section == 'body') {
            handler[1](group, match: matches.elementAt(0));
          } else {
            handler[1](group, match: matches.elementAt(0), section: section);
          }
          handler[2] = true;
          break;
        }

        if (handlers.indexOf(handler) == handlers.length - 1) {
          errorMessage = 'failed while processing "$group". Code: $_code.';
          logger.info(errorMessage);
          throw ParserError(errorMessage);
        }
      }
    });
  }

  void _createTrendHanldersListAndParse() {
    _trendHandlers = [
      [regex.WIND_RE, _handleWind, false],
      [regex.OPTIONALVIS_RE, _handleOptionalVisibility, false],
      [regex.VISIBILITY_RE, _handleVisibility, false],
      [regex.WEATHER_RE, _handleWeather, false],
      [regex.WEATHER_RE, _handleWeather, false],
      [regex.WEATHER_RE, _handleWeather, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.SKY_RE, _handleSky, false],
    ];

    _trendCode = _trendList == null ? null : _trendList[0];

    _string += '\n### TREND: ${_trendCode} ###\n';

    if (_trendList != null) {
      _parseGroups(_trendList.sublist(1), _trendHandlers, section: 'trend');
    }
  }

  void _createBodyHandlersListAndParse() {
    _bodyHandlers = [
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
      [regex.RUNWAY_RE, _handleRunway, false],
      [regex.RUNWAY_RE, _handleRunway, false],
      [regex.WEATHER_RE, _handleWeather, false],
      [regex.WEATHER_RE, _handleWeather, false],
      [regex.WEATHER_RE, _handleWeather, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.SKY_RE, _handleSky, false],
      [regex.TEMP_RE, _handleTemperatures, false],
      [regex.PRESS_RE, _handlePressure, false],
      [regex.RECENT_RE, _handleRecent, false],
      [regex.WINDSHEAR_PREFIX_RE, _handleWindShearPrefix, false],
      [regex.WINDSHEAR_PREFIX_RE, _handleWindShearPrefix, false],
      [regex.WINDSHEAR_RUNWAY_RE, _handleWindShearRunway, false],
    ];

    _parseGroups(_bodyList, _bodyHandlers);
  }

  // Body getters
  int get month => _month;
  int get year => _year;
  String get code => _code;
  String get rmk => _rmk;
  List<String> get bodyList => _bodyList;
  String get type => _type;
  DateTime get time => _time;
  bool get correction => _correction;
  String get stationID => _stationID;
  Station get station => _station;
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
  Pressure get pressure => _press;
  List<String> get recentWeather => _recent;
  List<String> get windshear => _windshear;

  // Trend getters
  String get trendCode => _trendCode;
  Direction get trendWindDir => _trendWindDir;
  Speed get trendWindSpeed => _trendWindSpeed;
  Speed get trendWindGust => _trendWindGust;
  Length get trendVisibility => _trendVis;
  List<Tuple5> get trendWeather => _trendWeather;
  List<Tuple3> get trendSky => _trendSky;
}
