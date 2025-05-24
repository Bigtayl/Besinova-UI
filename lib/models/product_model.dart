class Product {
  final int id;
  final String name;
  final String market;
  final String price;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final String? imageUrl;
  final String? category;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.market,
    required this.price,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.imageUrl,
    this.category,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      market: json['market'],
      price: json['price'],
      caloriesPer100g: (json['caloriesPer100g'] as num?)?.toDouble(),
      proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble(),
      carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble(),
      fatPer100g: (json['fatPer100g'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
