import 'dart:convert';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:coffee/models/coffee_image.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class CoffeeRepository {
  late final Database _database;
  final http.Client httpClient;

  CoffeeRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client() {
    _initDatabase();
  }

  void _initDatabase() {
    final path = _getDefaultDatabasePath();
    _database = sqlite3.open(path);
    _createDb(_database);
  }

  String _getDefaultDatabasePath() {
    final documentsDirectory = Directory.systemTemp;
    return join(documentsDirectory.path, 'coffee.db');
  }

  void _createDb(Database db) {
    db.execute('CREATE TABLE IF NOT EXISTS favorites (id INTEGER PRIMARY KEY, url TEXT)');
  }

  Future<CoffeeImage> fetchCoffeeImage() async {
    final response = await httpClient
        .get(Uri.parse('https://coffee.alexflipnote.dev/random.json'));
    if (response.statusCode == 200) {
      return CoffeeImage.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load coffee image');
    }
  }

  Future<void> saveFavorite(CoffeeImage image) async {
    _database.execute('INSERT INTO favorites (url) VALUES (?)', [image.url]);
  }

  List<CoffeeImage> getFavorites() {
    final result = _database.select('SELECT url FROM favorites');
    return result.map((row) => CoffeeImage(url: row['url'] as String)).toList();
  }

  Future<void> deleteFavorite(String url) async {
    _database.execute('DELETE FROM favorites WHERE url = ?', [url]);
  }
}
