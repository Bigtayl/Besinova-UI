import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

/// Service for managing favorite products
class FavoritesService {
  static const String _favoritesKey = 'favorites';
  static SharedPreferences? _prefs;

  /// Initialize the favorites service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('FavoritesService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// Add a product to favorites
  static Future<bool> addToFavorites(Product product) async {
    try {
      await init();
      List<Product> favorites = await getFavorites();

      // Check if product is already in favorites
      if (favorites.any((p) => p.id == product.id)) {
        return false; // Already in favorites
      }

      favorites.add(product);
      await _saveFavorites(favorites);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove a product from favorites
  static Future<bool> removeFromFavorites(int productId) async {
    try {
      await init();
      List<Product> favorites = await getFavorites();

      favorites.removeWhere((product) => product.id == productId);
      await _saveFavorites(favorites);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all favorite products
  static Future<List<Product>> getFavorites() async {
    try {
      await init();
      final String? favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }

      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if a product is in favorites
  static Future<bool> isFavorite(int productId) async {
    try {
      List<Product> favorites = await getFavorites();
      return favorites.any((product) => product.id == productId);
    } catch (e) {
      return false;
    }
  }

  /// Toggle favorite status of a product
  static Future<bool> toggleFavorite(Product product) async {
    try {
      bool isFav = await isFavorite(product.id);

      if (isFav) {
        return await removeFromFavorites(product.id);
      } else {
        return await addToFavorites(product);
      }
    } catch (e) {
      return false;
    }
  }

  /// Clear all favorites
  static Future<bool> clearFavorites() async {
    try {
      await init();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save favorites to SharedPreferences
  static Future<void> _saveFavorites(List<Product> favorites) async {
    final List<Map<String, dynamic>> favoritesJson =
        favorites.map((product) => product.toJson()).toList();
    await prefs.setString(_favoritesKey, json.encode(favoritesJson));
  }
}
