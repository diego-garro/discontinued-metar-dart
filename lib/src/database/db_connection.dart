import 'package:postgres/postgres.dart';

class PostgresConnection {
  PostgreSQLConnection _connection;

  PostgresConnection() {
    // final hostIP = '192.168.1.9';
    final hostIP = '127.0.0.1';
    final port = 5432;
    final dbName = 'test';
    _connection = PostgreSQLConnection(hostIP, port, dbName,
        username: 'postgres', password: 'postgres');
  }

  /// Returns a query result with the match of a station as a List
  Future<List<dynamic>> queryAsList(String station) async {
    await _connection.open();
    var result = await _connection.query(
      'SELECT * FROM stations WHERE "ICAO" = @value',
      substitutionValues: {'value': station.toUpperCase()},
    );
    await _connection.close();

    return result[0];
  }
}

// void main() async {
//   var conn = PostgresConnection();

//   final res = await conn.queryAsList('kjfk');
//   print(res);
// }
