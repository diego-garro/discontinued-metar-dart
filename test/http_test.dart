import 'package:http/http.dart' as http;

var url = 'http://tgftp.nws.noaa.gov/data/observations/metar/stations/MROC.TXT';

void main() async {
  var response = await http.get(url);
  print('Response status: ${response.statusCode}');
  print('Response body: \n${response.body}');

  var body = response.body.split('\n');
  print(body);
}
