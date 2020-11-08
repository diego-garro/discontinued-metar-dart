import '../lib/metar.dart';

void main() async {
  // var metarcode =
  //     'METAR MROC 071200Z COR P49MPS 250V110 0500 R07/P2000N BR VV003 17/09 A2994 RESHRA NOSIG';
  var metarcode =
      'NFNM 122100Z 13025G35KT 5000 3000NW R07L/M0050D 270V100 +RA BR VCTS SCT025 28/27 Q1014';
  // var metarcode =
  //     'CYQU 161518Z 05013KT 1 1/4SM -SN VV009 M02/M03 A2993 RMK SN8 SLP168';
  var metar = Metar(metarcode);
  // var metar = Metar('');
  var metarStation = await metar.station;

  print('Elevation of station: ${metarStation.elevation}');
  print('Name of station: ${metarStation.name}');
  print('Code: ${metar.code}');
  print('CodeList: ${metar.codeList}');
  print('Month: ${metar.month}');
  print('Year: ${metar.year}');
  print('Type: ${metar.type}');
  print('Time: ${metar.time}');
  print('Correction: ${metar.correction}');
  print('StationID: ${metar.stationID}');
  print('Modifier: ${metar.modifier}');
  // print('Wind direction: ${metar.windDir.directionInDegrees} degrees');
  print('Wind direction: ${metar.windDir.directionInDegrees}');
  print('Wind direction: ${metar.windDir.cardinalPoint}');
  print('Wind speed: ${metar.windSpeed.inMeterPerSecond} knots');
  print('Wind gust: ${metar.windGust.inKnot} knots');
  print('Wind variation from: ${metar.windDirFrom.directionInDegrees}');
  print('Wind variation from: ${metar.windDirFrom.cardinalPoint}');
  print('Wind variation to: ${metar.windDirTo.directionInDegrees}');
  print('Wind variation to: ${metar.windDirTo.cardinalPoint}');
  print('Visibility: ${metar.visibility.inMeters}');
  print('Max. Visibility: ${metar.maxVisibility.inKilometers}');
  print(
      'Max. Visibility Direction: ${metar.maxVisibilityDirection.directionInDegrees}');
  print('Runway: ${metar.runway}');
  print('Weather: ${metar.weather}');
}
