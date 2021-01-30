import 'package:postgres/postgres.dart';

class PostgresConnection {
  PostgreSQLConnection _connection;

  PostgresConnection() {
    _connection = PostgreSQLConnection('127.0.0.1', 5432, 'test_db',
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
