import 'dart:typed_data';

import 'package:metar/src/units/angle.dart';

class Direction {
  /*
   * The value of this direction from Metar report
  */
  final Map<String, double> _compassDirs = {
    'N': 0.0,
    'NNE': 22.5,
    'NE': 45.0,
    'ENE': 67.5,
    'E': 90.0,
    'ESE': 112.5,
    'SE': 135.0,
    'SSE': 157.5,
    'S': 180.0,
    'SSW': 202.5,
    'SW': 225.0,
    'WSW': 247.5,
    'W': 270.0,
    'WNW': 292.5,
    'NW': 315.0,
    'NNW': 337.5,
  };
  Angle _direction;
  String _directionStr;

  Direction.fromDegrees({String value = '000'}) {
    _direction = Angle.fromDegrees(value: double.parse(value));
    _directionStr = '${_direction.inDegrees}';
  }
  Direction.fromUndefined({String value = '///'}) {
    if (_compassDirs.keys.toList().contains(value)) {
      _direction = Angle.fromDegrees(value: _compassDirs[value]);
      _directionStr = '${_direction.inDegrees}';
    } else {
      _direction = Angle.fromDegrees(value: 0.0);
      _directionStr = value;
    }
  }

  double get directionInDegrees => _returnValue('degrees');
  double get directionInRadians => _returnValue('radians');
  double get directionInGradians => _returnValue('gradians');
  String get direction => _directionStr;

  double _returnValue(String format) {
    if (_directionStr == 'VRB' ||
        _directionStr == '///' ||
        _directionStr == 'MMM') {
      return null;
    }
    if (format == 'degrees') {
      return _direction.inDegrees;
    } else if (format == 'radians') {
      return _direction.inRadians;
    } else {
      return _direction.inGradians;
    }
  }
}
