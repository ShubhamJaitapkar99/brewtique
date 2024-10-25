import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee/main.dart';
import 'package:coffee/favorite_page.dart';
// import 'package:coffee/providers.dart';

void main() {
  testWidgets('App starts and displays loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Displays No coffee images available message when no images are loaded', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('No coffee images available'), findsOneWidget);
  });

  testWidgets('Favorite icon button navigates to FavoritesPage', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    final favoritesIcon = find.byIcon(Icons.favorite);
    expect(favoritesIcon, findsOneWidget);

    await tester.tap(favoritesIcon);
    await tester.pumpAndSettle();

    expect(find.byType(FavoritesPage), findsOneWidget);
  });

  testWidgets('Switching theme changes theme mode', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    final container = ProviderScope.containerOf(tester.element(switchFinder));
    expect(container.read(themeModeProvider), ThemeMode.light);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('Adding image to favorites displays Snackbar confirmation', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    final tickButton = find.byIcon(Icons.check);
    expect(tickButton, findsOneWidget);

    await tester.tap(tickButton);
    await tester.pump();

    expect(find.text('Image added to favorites'), findsOneWidget);
  });

  testWidgets('Attempting to re-add favorite image displays already in favorites Snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    final tickButton = find.byIcon(Icons.check);
    await tester.tap(tickButton);
    await tester.pump();


    await tester.tap(tickButton);
    await tester.pump();

    expect(find.text('Image already in favorites'), findsOneWidget);
  });

  testWidgets('No Favorites yet text displayed when favorites list is empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: FavoritesPage()),
      ),
    );

    expect(find.text('No Favorites yet'), findsOneWidget);
  });
}
