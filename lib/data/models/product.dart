/// Product model representing nutritional products in the application
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.market,
    required this.price,
    this.imageUrl,
    this.category,
    this.subcategory,
    this.itemCategory,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.weightG,
    this.mainGroup,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String market;
  final double price;
  final String? imageUrl;
  final String? category;
  final String? subcategory;
  final String? itemCategory;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final int? weightG;
  final String? mainGroup;
  final DateTime createdAt;

  /// Creates a Product from JSON data
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String,
        market: json['market'] as String,
        price: (json['price'] is String)
            ? double.tryParse(json['price'] as String) ?? 0.0
            : (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String?,
        category: json['category'] as String?,
        subcategory: json['subcategory'] as String?,
        itemCategory: json['itemCategory'] as String?,
        caloriesPer100g: (json['caloriesPer100g'] as num?)?.toDouble(),
        proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble(),
        carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble(),
        fatPer100g: (json['fatPer100g'] as num?)?.toDouble(),
        weightG: json['weightG'] as int?,
        mainGroup: json['mainGroup'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Creates a Product from CSV row data
  static Product fromCsvRow(Map<String, dynamic> row, int id) {
    try {
      // Parse price - handle Turkish price format
      double price = 0.0;
      if (row['price'] != null) {
        String priceStr = row['price']
            .toString()
            .replaceAll(' TL', '')
            .replaceAll('.', '')
            .replaceAll(',', '.');
        price = double.tryParse(priceStr) ?? 0.0;
      }

      // Parse nutrition values, default to 0.0 if missing or invalid
      double calories =
          double.tryParse(row['calories']?.toString() ?? '') ?? 0.0;
      double protein = double.tryParse(row['protein']?.toString() ?? '') ?? 0.0;
      double carbs = double.tryParse(row['carbs']?.toString() ?? '') ?? 0.0;
      double fat = double.tryParse(row['fat']?.toString() ?? '') ?? 0.0;

      // Extract weight from name
      int weightG = _extractWeightFromName(row['name']?.toString() ?? '');

      Product product = Product(
        id: id,
        name: row['name']?.toString() ?? '',
        market: row['market']?.toString() ?? '',
        price: price,
        imageUrl: row['image_url']?.toString(),
        category: row['category']?.toString(),
        subcategory: row['subcategory']?.toString(),
        itemCategory: row['item_category']?.toString(),
        caloriesPer100g: calories,
        proteinPer100g: protein,
        carbsPer100g: carbs,
        fatPer100g: fat,
        weightG: weightG,
        mainGroup: _mapMainGroup(row),
        createdAt: DateTime.now(),
      );

      return product;
    } catch (e) {
      rethrow;
    }
  }

  /// Extract weight from product name
  static int _extractWeightFromName(String name) {
    final regex = RegExp(r'(\d+[.,]?\d*)\s*(kg|g|gr)', caseSensitive: false);
    final match = regex.firstMatch(name);
    if (match != null) {
      double value = double.parse(match.group(1)!.replaceAll(',', '.'));
      String unit = match.group(2)!.toLowerCase();
      if (unit.contains('kg')) {
        return (value * 1000).round(); // Convert kg to grams
      } else {
        return value.round(); // Already in grams
      }
    }
    return 1000; // Default weight in grams
  }

  /// Map product to main group category
  static String _mapMainGroup(Map<String, dynamic> row) {
    String itemCategory =
        (row['item_category']?.toString() ?? '').toLowerCase();
    String name = (row['name']?.toString() ?? '').toLowerCase();

    // Exclude granola items
    if (itemCategory.contains('granola') || name.contains('granola')) {
      return 'exclude';
    }

    // Vegetables
    if (itemCategory.contains('sebze') ||
        itemCategory.contains('domates') ||
        itemCategory.contains('biber') ||
        itemCategory.contains('salatalık') ||
        itemCategory.contains('patates') ||
        itemCategory.contains('soğan') ||
        itemCategory.contains('havuç') ||
        name.contains('domates') ||
        name.contains('biber') ||
        name.contains('salatalık') ||
        name.contains('patates') ||
        name.contains('soğan') ||
        name.contains('havuç') ||
        name.contains('kabak')) {
      return 'vegetables';
    }

    // Fruits
    if (itemCategory.contains('meyve') ||
        itemCategory.contains('elma') ||
        itemCategory.contains('muz') ||
        itemCategory.contains('portakal') ||
        itemCategory.contains('armut') ||
        itemCategory.contains('çilek') ||
        name.contains('elma') ||
        name.contains('muz') ||
        name.contains('portakal') ||
        name.contains('armut') ||
        name.contains('çilek') ||
        name.contains('kayısı') ||
        name.contains('şeftali')) {
      return 'fruits';
    }

    // Dairy
    if (itemCategory.contains('süt') ||
        itemCategory.contains('kahvalt') ||
        itemCategory.contains('peynir') ||
        itemCategory.contains('yoğurt') ||
        itemCategory.contains('süt ürünleri') ||
        name.contains('peynir') ||
        name.contains('yoğurt') ||
        name.contains('süt') ||
        name.contains('kaymak') ||
        name.contains('krema')) {
      return 'dairy';
    }

    // Legumes
    if (itemCategory.contains('bakliyat') ||
        itemCategory.contains('fasulye') ||
        itemCategory.contains('mercimek') ||
        itemCategory.contains('nohut') ||
        itemCategory.contains('bezelye') ||
        name.contains('fasulye') ||
        name.contains('mercimek') ||
        name.contains('nohut') ||
        name.contains('bezelye') ||
        name.contains('barbunya')) {
      return 'legumes';
    }

    // Meat/Fish
    if (itemCategory.contains('et') ||
        itemCategory.contains('balık') ||
        itemCategory.contains('tavuk') ||
        itemCategory.contains('kıyma') ||
        itemCategory.contains('sucuk') ||
        name.contains('tavuk') ||
        name.contains('balık') ||
        name.contains('kıyma') ||
        name.contains('sucuk') ||
        name.contains('salam') ||
        name.contains('pastırma')) {
      return 'meat_fish';
    }

    // Grains
    if (itemCategory.contains('temel gıda') ||
        itemCategory.contains('ekmek') ||
        itemCategory.contains('bulgur') ||
        itemCategory.contains('pirinç') ||
        itemCategory.contains('makarna') ||
        itemCategory.contains('un') ||
        name.contains('ekmek') ||
        name.contains('bulgur') ||
        name.contains('pirinç') ||
        name.contains('makarna') ||
        name.contains('un') ||
        name.contains('börek')) {
      return 'grains';
    }

    return 'other';
  }

  /// Converts Product to JSON data
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'market': market,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'subcategory': subcategory,
        'itemCategory': itemCategory,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatPer100g': fatPer100g,
        'weightG': weightG,
        'mainGroup': mainGroup,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Creates a copy of this Product with updated fields
  Product copyWith({
    int? id,
    String? name,
    String? market,
    double? price,
    String? imageUrl,
    String? category,
    String? subcategory,
    String? itemCategory,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    int? weightG,
    String? mainGroup,
    DateTime? createdAt,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        market: market ?? this.market,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        category: category ?? this.category,
        subcategory: subcategory ?? this.subcategory,
        itemCategory: itemCategory ?? this.itemCategory,
        caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
        proteinPer100g: proteinPer100g ?? this.proteinPer100g,
        carbsPer100g: carbsPer100g ?? this.carbsPer100g,
        fatPer100g: fatPer100g ?? this.fatPer100g,
        weightG: weightG ?? this.weightG,
        mainGroup: mainGroup ?? this.mainGroup,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Product(id: $id, name: $name, market: $market, price: $price)';
}
