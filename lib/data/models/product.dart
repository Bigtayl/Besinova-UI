/// Product model representing nutritional products in the application
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.market,
    required this.price,
    this.imageUrl,
    this.category,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String market;
  final double price;
  final String? imageUrl;
  final String? category;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
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
        caloriesPer100g: (json['caloriesPer100g'] as num?)?.toDouble(),
        proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble(),
        carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble(),
        fatPer100g: (json['fatPer100g'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Converts Product to JSON data
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'market': market,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatPer100g': fatPer100g,
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
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    DateTime? createdAt,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        market: market ?? this.market,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        category: category ?? this.category,
        caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
        proteinPer100g: proteinPer100g ?? this.proteinPer100g,
        carbsPer100g: carbsPer100g ?? this.carbsPer100g,
        fatPer100g: fatPer100g ?? this.fatPer100g,
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
