import 'package:metar/src/units/angle.dart';
import 'package:metar/src/units/position.dart';

class Station {
  final String _name;
  final String _icao;
  final String _iata;
  final String _synop;
  String _lat;
  String _long;
  final String _elev;
  final String _country;
  Position _position;

  Station(this._name, this._icao, this._iata, this._synop, this._lat,
      this._long, this._elev, this._country) {
    if (_lat.contains('S')) {
      _lat = '-' + _lat.replaceFirst('S', '');
    } else {
      _lat = _lat.replaceFirst('N', '');
    }
    if (_long.contains('W')) {
      _long = '-' + _long.replaceFirst('W', '');
    } else {
      _long = _long.replaceFirst('E', '');
    }
    _position = Position(double.parse(_lat), double.parse(_long));
  }

  String get name => _name;
  String get icao => _icao;
  String get iata {
    if (_iata == '   ') {
      return 'NaN';
    }
    return _iata;
  }

  String get synop {
    if (_synop == '     ') {
      return 'NaN';
    }
    return _synop;
  }

  // double get latitude => double.parse(_lat);
  // double get longitude => double.parse(_long);
  int get elevation => int.parse(_elev);
  String get country => _country;
  Position get position => _position;
  Angle get longitude => _position.longitude;
  Angle get latitude => _position.latitude;
}
