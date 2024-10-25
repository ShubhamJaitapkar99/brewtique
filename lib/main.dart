import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'favorite_page.dart';
import 'models/coffee_image.dart';
import 'providers.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xfff5f5f5),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xfff5f5f5)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
      themeMode: themeMode,
      home: const CoffeeHomePage(),
    );
  }
}

class CoffeeHomePage extends ConsumerStatefulWidget {
  const CoffeeHomePage({super.key});

  @override
  _CoffeeHomePageState createState() => _CoffeeHomePageState();
}

class _CoffeeHomePageState extends ConsumerState<CoffeeHomePage> {
  final List<CoffeeImage> _coffeeImages = [];
  final Set<String> _shownImages = {};
  bool _loading = false;
  int _swipeCount = 0;
  final CardSwiperController _swiperController = CardSwiperController();
  int _currentIndex = 0;
  bool _justAddedToFavorites = false;
  CoffeeImage? _lastRejectedImage;

  @override
  void initState() {
    super.initState();
    _fetchInitialImages();
  }

  Future<void> _fetchInitialImages() async {
    setState(() {
      _loading = true;
    });
    try {
      for (int i = 0; i < 5; i++) {
        final image = await _fetchUniqueImage();
        _coffeeImages.add(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load some images.',
                style: GoogleFonts.poppins()),
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<CoffeeImage> _fetchUniqueImage() async {
    CoffeeImage image;
    do {
      image = await ref.read(coffeeRepositoryProvider).fetchCoffeeImage();
    } while (_shownImages.contains(image.url));

    _shownImages.add(image.url);
    return image;
  }

  Future<void> _addNewImage() async {
    try {
      final newImage = await _fetchUniqueImage();
      if (mounted) {
        setState(() {
          _coffeeImages.add(newImage);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load a new image.',
                style: GoogleFonts.poppins()),
          ),
        );
      }
    }
  }

  Future<void> _addToFavorites(CoffeeImage image) async {
    final favorites = ref.watch(favoritesProvider);

    if (favorites.any((fav) => fav.url == image.url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Image already in favorites',
              style: GoogleFonts.poppins(),
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      await ref.read(favoritesProvider.notifier).addFavorite(image);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Image added to favorites',
              style: GoogleFonts.poppins(),
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onCrossButtonTapped() {
    _swiperController.swipe(CardSwiperDirection.left);
  }

  void _onTickButtonTapped() async {
    if (_currentIndex < _coffeeImages.length) {
      final image = _coffeeImages[_currentIndex];
      final favorites = ref.read(favoritesProvider.notifier).getFavorites();

      if (favorites.any((fav) => fav.url == image.url)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Image already in favorites',
                style: GoogleFonts.poppins(),
              ),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        await _addToFavorites(image);
        _justAddedToFavorites = true;
      }
      _swiperController.swipe(CardSwiperDirection.right);
    }
  }

  void _onRecallButtonTapped() {
    if (_lastRejectedImage != null) {
      setState(() {
        _coffeeImages.insert(_currentIndex, _lastRejectedImage!);
        _lastRejectedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final swiperHeight = screenHeight * 0.55;
    final buttonPadding = screenHeight * 0.05;
    final buttonSize = screenWidth * 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Brewtique',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.06,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Transform.scale(
            scale: 0.7,
            child: Switch(
              value: ref.watch(themeModeProvider) == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state =
                    value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _coffeeImages.isEmpty
              ? Center(
                  child: Text(
                    'No coffee images available',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.06,
                    ),
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      height: swiperHeight,
                      child: CardSwiper(
                        controller: _swiperController,
                        cardsCount: _coffeeImages.length,
                        numberOfCardsDisplayed:
                            _coffeeImages.length < 3 ? _coffeeImages.length : 3,
                        cardBuilder: (context,
                            index,
                            horizontalOffsetPercentage,
                            verticalOffsetPercentage) {
                          return AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: CachedNetworkImage(
                                imageUrl: _coffeeImages[index].url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Center(
                                  child: Text(
                                    'Unable to load the image',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        onSwipe:
                            (previousIndex, currentIndex, direction) async {
                          if (direction == CardSwiperDirection.right) {
                            if (_justAddedToFavorites) {
                              _justAddedToFavorites = false;
                            } else {
                              await _addToFavorites(
                                  _coffeeImages[previousIndex]);
                            }
                          } else if (direction == CardSwiperDirection.left) {
                            setState(() {
                              _lastRejectedImage = _coffeeImages[previousIndex];
                            });
                          }

                          _swipeCount += 1;

                          if (_swipeCount >= 3) {
                            _swipeCount = 0;
                            await _addNewImage();
                          }

                          setState(() {
                            _currentIndex = currentIndex ?? 0;
                          });

                          return true;
                        },
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        duration: const Duration(milliseconds: 500),
                      ),
                    ),
                    SizedBox(
                      height: buttonPadding,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: FloatingActionButton(
                              onPressed: _lastRejectedImage != null
                                  ? _onRecallButtonTapped
                                  : null,
                              backgroundColor: _lastRejectedImage != null
                                  ? Colors.blue
                                  : Colors.grey,
                              heroTag: 'recall',
                              child:
                                  const Icon(Icons.replay, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: FloatingActionButton(
                              onPressed: _onCrossButtonTapped,
                              backgroundColor: Colors.red,
                              heroTag: 'cross',
                              child:
                                  const Icon(Icons.clear, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: FloatingActionButton(
                              onPressed: _onTickButtonTapped,
                              backgroundColor: Colors.green,
                              heroTag: 'tick',
                              child:
                                  const Icon(Icons.check, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
