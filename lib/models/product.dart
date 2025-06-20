// product.dart
// Ürün modeli: Besin önerileri için kullanılan ürün bilgilerini içerir.

/// Ürün modeli
class Product {
  final String name;
  final String market;
  final double price;
  final String imageUrl;

  Product({
    required this.name,
    required this.market,
    required this.price,
    required this.imageUrl,
  });
}
