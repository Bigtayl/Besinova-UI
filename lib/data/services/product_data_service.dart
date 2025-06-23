import '../models/product.dart';

/// Service for providing product data
class ProductDataService {
  /// Get sample products for testing optimization
  static List<Product> getSampleProducts() {
    return [
      // Vegetables
      Product(
        id: 1,
        name: 'Domates 1kg',
        market: 'Carrefoursa',
        price: 12.90,
        category: 'Meyve & Sebze',
        caloriesPer100g: 18,
        proteinPer100g: 0.9,
        carbsPer100g: 3.9,
        fatPer100g: 0.2,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 2,
        name: 'Salatalık 500g',
        market: 'BİM',
        price: 8.50,
        category: 'Meyve & Sebze',
        caloriesPer100g: 16,
        proteinPer100g: 0.7,
        carbsPer100g: 3.6,
        fatPer100g: 0.1,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 3,
        name: 'Patates 2.5kg',
        market: 'Migros',
        price: 24.90,
        category: 'Meyve & Sebze',
        caloriesPer100g: 77,
        proteinPer100g: 2.0,
        carbsPer100g: 17.0,
        fatPer100g: 0.1,
        createdAt: DateTime.now(),
      ),

      // Fruits
      Product(
        id: 4,
        name: 'Elma 1kg',
        market: 'Carrefoursa',
        price: 15.90,
        category: 'Meyve & Sebze',
        caloriesPer100g: 52,
        proteinPer100g: 0.3,
        carbsPer100g: 14.0,
        fatPer100g: 0.2,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 5,
        name: 'Muz 1kg',
        market: 'BİM',
        price: 18.90,
        category: 'Meyve & Sebze',
        caloriesPer100g: 89,
        proteinPer100g: 1.1,
        carbsPer100g: 23.0,
        fatPer100g: 0.3,
        createdAt: DateTime.now(),
      ),

      // Dairy
      Product(
        id: 6,
        name: 'Süt Tam Yağlı 1L',
        market: 'Migros',
        price: 24.90,
        category: 'Süt & Kahvaltı',
        caloriesPer100g: 64,
        proteinPer100g: 3.2,
        carbsPer100g: 4.8,
        fatPer100g: 3.6,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 7,
        name: 'Beyaz Peynir 500g',
        market: 'Carrefoursa',
        price: 45.90,
        category: 'Süt & Kahvaltı',
        caloriesPer100g: 264,
        proteinPer100g: 18.0,
        carbsPer100g: 2.0,
        fatPer100g: 20.0,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 8,
        name: 'Yoğurt 500g',
        market: 'BİM',
        price: 12.90,
        category: 'Süt & Kahvaltı',
        caloriesPer100g: 59,
        proteinPer100g: 10.0,
        carbsPer100g: 3.6,
        fatPer100g: 0.4,
        createdAt: DateTime.now(),
      ),

      // Meat/Fish
      Product(
        id: 9,
        name: 'Tavuk Göğsü 1kg',
        market: 'Migros',
        price: 89.90,
        category: 'Et & Tavuk',
        caloriesPer100g: 165,
        proteinPer100g: 31.0,
        carbsPer100g: 0.0,
        fatPer100g: 3.6,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 10,
        name: 'Dana Kıyma 500g',
        market: 'Carrefoursa',
        price: 120.00,
        category: 'Et & Tavuk',
        caloriesPer100g: 250,
        proteinPer100g: 26.0,
        carbsPer100g: 0.0,
        fatPer100g: 15.0,
        createdAt: DateTime.now(),
      ),

      // Grains
      Product(
        id: 11,
        name: 'Ekmek 500g',
        market: 'BİM',
        price: 8.90,
        category: 'Temel Gıda',
        caloriesPer100g: 265,
        proteinPer100g: 9.0,
        carbsPer100g: 49.0,
        fatPer100g: 3.2,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 12,
        name: 'Pirinç 1kg',
        market: 'Migros',
        price: 32.90,
        category: 'Temel Gıda',
        caloriesPer100g: 130,
        proteinPer100g: 2.7,
        carbsPer100g: 28.0,
        fatPer100g: 0.3,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 13,
        name: 'Makarna 500g',
        market: 'Carrefoursa',
        price: 15.90,
        category: 'Temel Gıda',
        caloriesPer100g: 131,
        proteinPer100g: 5.0,
        carbsPer100g: 25.0,
        fatPer100g: 1.1,
        createdAt: DateTime.now(),
      ),

      // Legumes
      Product(
        id: 14,
        name: 'Kırmızı Mercimek 500g',
        market: 'BİM',
        price: 18.90,
        category: 'Bakliyat',
        caloriesPer100g: 116,
        proteinPer100g: 9.0,
        carbsPer100g: 20.0,
        fatPer100g: 0.4,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 15,
        name: 'Nohut 500g',
        market: 'Migros',
        price: 22.90,
        category: 'Bakliyat',
        caloriesPer100g: 164,
        proteinPer100g: 8.9,
        carbsPer100g: 27.0,
        fatPer100g: 2.6,
        createdAt: DateTime.now(),
      ),

      // Additional products for variety
      Product(
        id: 16,
        name: 'Havuç 1kg',
        market: 'Carrefoursa',
        price: 9.90,
        category: 'Meyve & Sebze',
        caloriesPer100g: 41,
        proteinPer100g: 0.9,
        carbsPer100g: 10.0,
        fatPer100g: 0.2,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 17,
        name: 'Soğan 1kg',
        market: 'BİM',
        price: 7.90,
        category: 'Meyve & Sebze',
        caloriesPer100g: 40,
        proteinPer100g: 1.1,
        carbsPer100g: 9.3,
        fatPer100g: 0.1,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 18,
        name: 'Portakal 1kg',
        market: 'Migros',
        price: 16.90,
        category: 'Meyve & Sebze',
        caloriesPer100g: 47,
        proteinPer100g: 0.9,
        carbsPer100g: 12.0,
        fatPer100g: 0.1,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 19,
        name: 'Bulgur 1kg',
        market: 'Carrefoursa',
        price: 28.90,
        category: 'Temel Gıda',
        caloriesPer100g: 342,
        proteinPer100g: 12.0,
        carbsPer100g: 76.0,
        fatPer100g: 1.3,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 20,
        name: 'Balık Filetosu 500g',
        market: 'Migros',
        price: 95.90,
        category: 'Et & Tavuk',
        caloriesPer100g: 206,
        proteinPer100g: 22.0,
        carbsPer100g: 0.0,
        fatPer100g: 12.0,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Get products by category
  static List<Product> getProductsByCategory(String category) {
    return getSampleProducts().where((product) => product.category == category).toList();
  }

  /// Get products by price range
  static List<Product> getProductsByPriceRange(double minPrice, double maxPrice) {
    return getSampleProducts().where((product) => 
      product.price >= minPrice && product.price <= maxPrice
    ).toList();
  }

  /// Search products by name
  static List<Product> searchProducts(String query) {
    if (query.isEmpty) return getSampleProducts();
    
    return getSampleProducts().where((product) => 
      product.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Get products with nutritional data
  static List<Product> getProductsWithNutrition() {
    return getSampleProducts().where((product) => 
      (product.caloriesPer100g ?? 0) > 0 &&
      (product.proteinPer100g ?? 0) > 0 &&
      (product.carbsPer100g ?? 0) > 0 &&
      (product.fatPer100g ?? 0) > 0
    ).toList();
  }

  /// Get categories
  static List<String> getCategories() {
    final categories = getSampleProducts().map((product) => product.category ?? 'Diğer').toSet();
    return ['Tümü', ...categories.toList()];
  }

  /// Get markets
  static List<String> getMarkets() {
    return getSampleProducts().map((product) => product.market).toSet().toList();
  }
} 