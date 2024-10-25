import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/coffee_image.dart';
import 'providers.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final response = await http.get(Uri.parse(imageUrl));
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.bodyBytes),
        quality: 100,
        name: "coffee_image_${DateTime.now().millisecondsSinceEpoch}",
      );
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Image saved to gallery',
                style: GoogleFonts.poppins(),
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Failed to save image',
                style: GoogleFonts.poppins(),
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permission denied',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final titleFontSize = screenWidth * 0.06;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Favorites',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
            color:
                isDarkMode ? Colors.white : theme.textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text(
                'No Favorites yet',
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final CoffeeImage image = favorites[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      width: screenWidth * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: image.url,
                              fit: BoxFit.cover,
                              width: screenWidth * 0.92,
                              height: screenHeight * 0.25,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Center(
                                child: Text(
                                  'Unable to load the image',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: screenWidth * 0.05,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.file_download_outlined,
                                    color: theme.iconTheme.color,
                                    size: screenWidth * 0.06,
                                  ),
                                  onPressed: () {
                                    _downloadImage(context, image.url);
                                  },
                                ),
                                SizedBox(width: screenWidth * 0.05),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: screenWidth * 0.06,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(favoritesProvider.notifier)
                                        .removeFavorite(image);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
