// import 'package:coffee/favorite_page.dart';
import 'package:coffee/models/coffee_image.dart';
import 'package:coffee/repositories/coffee_repository.dart';
import 'package:coffee/providers.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:coffee/main.dart';
// import 'package:cached_network_image/cached_network_image.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CoffeeRepository Tests', () {
    late CoffeeRepository repository;

    setUp(() {
      repository = CoffeeRepository(
        httpClient: MockClient((request) async {
          final jsonResponse = '{"file": "https://coffee.example.com/image.jpg"}';
          return http.Response(jsonResponse, 200);
        }),
      );
    });

    test('Fetch Coffee Image returns a CoffeeImage', () async {
      final image = await repository.fetchCoffeeImage();
      expect(image, isA<CoffeeImage>());
      expect(image.url, isNotEmpty);
    });

    test('Save and Retrieve Favorite Coffee Images', () async {
      final image = CoffeeImage(url: 'https://coffee.example.com/image.jpg');
      await repository.saveFavorite(image);

      final favorites = repository.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.url, image.url);
    });

    test('Delete Favorite Coffee Image', () async {
      final image = CoffeeImage(url: 'https://coffee.example.com/image.jpg');
      await repository.saveFavorite(image);

      await repository.deleteFavorite(image.url);
      final favorites = repository.getFavorites();
      expect(favorites.isEmpty, true);
    });
  });

  group('FavoritesProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          coffeeRepositoryProvider.overrideWithValue(
            CoffeeRepository(
              httpClient: MockClient((request) async {
                final jsonResponse = '{"file": "https://coffee.example.com/image.jpg"}';
                return http.Response(jsonResponse, 200);
              }),
            ),
          ),
        ],
      );
    });

    test('Add and Remove Favorites in FavoritesProvider', () async {
      final coffeeImage = CoffeeImage(
          url: 'https://coffee.example.com/image.jpg');
      final notifier = container.read(favoritesProvider.notifier);

      await notifier.addFavorite(coffeeImage);
      expect(container
          .read(favoritesProvider)
          .length, 1);

      await notifier.removeFavorite(coffeeImage);
      expect(container
          .read(favoritesProvider)
          .isEmpty, true);
    });
  });

  group('CoffeeImageProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          coffeeRepositoryProvider.overrideWithValue(
            CoffeeRepository(
              httpClient: MockClient((request) async {
                final jsonResponse = '{"file": "https://coffee.example.com/image.jpg"}';
                return http.Response(jsonResponse, 200);
              }),
            ),
          ),
        ],
      );
    });

    test('Fetch new CoffeeImage and verify data', () async {
      final notifier = container.read(coffeeImageProvider.notifier);

      await notifier.fetchNewImage();
      expect(container
          .read(coffeeImageProvider)
          .value
          ?.url, isNotEmpty);
    });
  });
}