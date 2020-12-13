import 'package:metar/metar.dart';

void main() async {
  var metar = await Metar.mostRecentFromNOAA('mroc');

  var metarStation = await metar.station;

  print('Elevation of station: ${metarStation.elevation}');
  print('Name of station: ${metarStation.name}');
  print('Code: ${metar.code}');
  print('BodyList: ${metar.bodyList}');
  print('Month: ${metar.month}');
  print('Year: ${metar.year}');
  print('Type: ${metar.type}');
  print('Time: ${metar.time}');
  print('Correction: ${metar.correction}');
  print('StationID: ${metar.stationID}');
  print('Modifier: ${metar.modifier}');
  // print('Wind direction: ${metar.windDir.directionInDegrees} degrees');
  print('Wind direction: ${metar.windDir?.directionInDegrees}');
  print('Wind direction: ${metar.windDir?.cardinalPoint}');
  print('Wind speed: ${metar.windSpeed?.inMeterPerSecond} knots');
  print('Wind gust: ${metar.windGust?.inKnot} knots');
  print('Wind variation from: ${metar.windDirFrom?.directionInDegrees}');
  print('Wind variation from: ${metar.windDirFrom?.cardinalPoint}');
  print('Wind variation to: ${metar.windDirTo?.directionInDegrees}');
  print('Wind variation to: ${metar.windDirTo?.cardinalPoint}');
  print('Visibility: ${metar.visibility?.inMeters}');
  print('Max. Visibility: ${metar.maxVisibility?.inKilometers}');
  print(
      'Max. Visibility Direction: ${metar.maxVisibilityDirection?.directionInDegrees}');
  print('Runway: ${metar.runway}');
  print('Weather: ${metar.weather}');
  print('Sky: ${metar.sky}');
  for (var capa in metar.sky) {
    print('Un ${capa.item1} a ${capa.item2?.inMeters} metros de ${capa.item3}');
  }
  print('Temperature: ${metar.temperature?.inCelsius} °C');
  print('Dew Point Temperature: ${metar.dewPointTemperature?.inCelsius} °C');
  print('Pressure: ${metar.pressure?.inHPa} hPa');
  print('Recent weather: ${metar.recentWeather}');
  print('Wind Shear: ${metar.windshear}');
  //
  print('Trend code: ${metar.trendCode}');
  print(
      'Trend Wind Direction: ${metar.trendWindDir?.directionInDegrees} degrees');
  print('Trend Wind Speed: ${metar.trendWindSpeed?.inKnot} kt');
  print('Trend visibility: ${metar.trendVisibility?.inKilometers} km');
  print('Trend weather: ${metar.trendWeather}');
  print('Trend sky: ${metar.trendSky}');
  //
  print('Remark: ${metar.rmk}');
}
