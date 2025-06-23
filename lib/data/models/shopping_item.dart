/// ShoppingItem model representing items in the shopping list
class ShoppingItem {
  final String id;
  final String name;
  final String productName;
  final String market;
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;
  final double price;
  final int weightPerUnit;
  final int totalWeight;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String category;
  final String mainGroup;
  final String unit;
  final String imageUrl;
  final bool isChecked;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.productName,
    required this.market,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.price,
    required this.weightPerUnit,
    required this.totalWeight,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.category,
    required this.mainGroup,
    required this.unit,
    required this.imageUrl,
    this.isChecked = false,
  });

  /// Creates a ShoppingItem from JSON data
  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String,
        productName: json['productName'] as String? ?? json['name'] as String,
        market: json['market'] as String? ?? '',
        quantity: json['quantity'] as int,
        pricePerUnit: (json['pricePerUnit'] ?? json['price_per_unit']) as double,
        totalPrice: (json['totalPrice'] ?? json['total_price']) as double,
        price: (json['price'] ?? json['pricePerUnit'] ?? json['price_per_unit']) as double,
        weightPerUnit: (json['weightPerUnit'] ?? json['weight_per_unit']) as int,
        totalWeight: (json['totalWeight'] ?? json['total_weight']) as int,
        calories: (json['calories'] ?? 0.0) as double,
        protein: (json['protein'] ?? 0.0) as double,
        carbs: (json['carbs'] ?? 0.0) as double,
        fat: (json['fat'] ?? 0.0) as double,
        category: json['category'] as String? ?? '',
        mainGroup: json['mainGroup'] as String? ?? json['category'] as String? ?? '',
        unit: json['unit'] as String? ?? 'piece',
        imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
        isChecked: json['isChecked'] as bool? ?? false,
      );

  /// Converts ShoppingItem to JSON data
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'productName': productName,
        'market': market,
        'quantity': quantity,
        'pricePerUnit': pricePerUnit,
        'totalPrice': totalPrice,
        'price': price,
        'weightPerUnit': weightPerUnit,
        'totalWeight': totalWeight,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'category': category,
        'mainGroup': mainGroup,
        'unit': unit,
        'imageUrl': imageUrl,
        'isChecked': isChecked,
      };

  /// Creates a copy of this ShoppingItem with updated fields
  ShoppingItem copyWith({
    String? id,
    String? name,
    String? productName,
    String? market,
    int? quantity,
    double? pricePerUnit,
    double? totalPrice,
    double? price,
    int? weightPerUnit,
    int? totalWeight,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? category,
    String? mainGroup,
    String? unit,
    String? imageUrl,
    bool? isChecked,
  }) =>
      ShoppingItem(
        id: id ?? this.id,
        name: name ?? this.name,
        productName: productName ?? this.productName,
        market: market ?? this.market,
        quantity: quantity ?? this.quantity,
        pricePerUnit: pricePerUnit ?? this.pricePerUnit,
        totalPrice: totalPrice ?? this.totalPrice,
        price: price ?? this.price,
        weightPerUnit: weightPerUnit ?? this.weightPerUnit,
        totalWeight: totalWeight ?? this.totalWeight,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fat: fat ?? this.fat,
        category: category ?? this.category,
        mainGroup: mainGroup ?? this.mainGroup,
        unit: unit ?? this.unit,
        imageUrl: imageUrl ?? this.imageUrl,
        isChecked: isChecked ?? this.isChecked,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShoppingItem && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ShoppingItem(id: $id, name: $name, quantity: $quantity, pricePerUnit: $pricePerUnit)';
} 