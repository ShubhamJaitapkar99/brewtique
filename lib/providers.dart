import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/coffee_image.dart';
import 'repositories/coffee_repository.dart';

final coffeeRepositoryProvider = Provider<CoffeeRepository>((ref) {
  return CoffeeRepository();
});

class CoffeeImageNotifier extends StateNotifier<AsyncValue<CoffeeImage>> {
  CoffeeImageNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchNewImage();
  }

  final Ref ref;

  Future<void> fetchNewImage() async {
    try {
      state = const AsyncValue.loading();
      final image = await ref.read(coffeeRepositoryProvider).fetchCoffeeImage();
      state = AsyncValue.data(image);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final coffeeImageProvider =
StateNotifierProvider<CoffeeImageNotifier, AsyncValue<CoffeeImage>>(
        (ref) => CoffeeImageNotifier(ref));

class FavoritesNotifier extends StateNotifier<List<CoffeeImage>> {
  FavoritesNotifier(this.ref) : super([]) {
    _loadFavorites();
  }

  final Ref ref;

  Future<void> _loadFavorites() async {
    final favorites = await ref.read(coffeeRepositoryProvider).getFavorites();
    state = favorites;
  }

  Future<void> addFavorite(CoffeeImage image) async {
    if (!state.any((favorite) => favorite.url == image.url)) {
      await ref.read(coffeeRepositoryProvider).saveFavorite(image);
      state = [...state, image];
    }
  }

  Future<void> removeFavorite(CoffeeImage image) async {
    await ref.read(coffeeRepositoryProvider).deleteFavorite(image.url);
    state = state.where((favorite) => favorite.url != image.url).toList();
  }

  List<CoffeeImage> getFavorites() {
    return state;
  }
}

final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, List<CoffeeImage>>((ref) {
  return FavoritesNotifier(ref);
});
