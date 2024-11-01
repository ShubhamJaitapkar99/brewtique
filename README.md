# ☕ Brewtique - Coffee Image App

Brewtique is a Flutter application designed to let users explore and save random coffee images as favorites. It features a beautiful, cozy design with light and dark themes, offline storage of favorites, and a smooth user experience built with Riverpod and SQLite.

## 📋 Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Dependencies](#dependencies)

## ✨ Features

- **Random Coffee Images**: Swipe through unique, random coffee images fetched from an online API.
- **Favorites**: Save your favorite coffee images to a list for easy access later.
- **Dark Mode Support**: Toggle between light and dark themes using the switch in the app bar.
- **Offline Storage**: Favorite images are saved locally using SQLite, so they're accessible offline.
- **Responsive UI**: Optimized for both Android and iOS devices with a smooth and visually appealing design.

## 🚀 Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ShubhamJaitapkar99/brewtique.git

🛠️ Usage
Explore Coffee Images: Open the app to view a selection of random coffee images.
Add to Favorites: Tap the green check button to save an image to your favorites list.
View Favorites: Access your saved images by tapping the heart icon in the app bar.
Switch Themes: Toggle between light and dark mode using the switch on the left side of the app bar.

Testing Details
The tests cover:

App Startup: Verifies that the app starts with a loading indicator.
Favorites Management: Tests adding, removing, and displaying favorite coffee images.
Theme Switching: Ensures the app toggles between light and dark themes.
Snackbar Notifications: Confirms appropriate feedback for adding or removing favorites.

📦 Dependencies
Flutter: The primary framework for building cross-platform mobile apps.
Riverpod: State management for managing app state and providers.
SQLite: Local database for saving favorite coffee images.
cached_network_image: Caches images to improve loading performance.
flutter_test: Testing framework for writing and running unit and widget tests.
google_fonts: Access to Google Fonts for a stylish UI.
permission_handler: Requests permissions for saving images to the gallery.
