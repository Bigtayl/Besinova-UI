import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final String _baseUrl = 'http://10.0.2.2:5019/api/product';
  // Eğer emülatör yerine fiziksel cihaz kullanırsan, burayı kendi IP adresinle değiştirmen gerekebilir

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Products couldnt get. Hata kodu: ${response.statusCode}');
    }
  }
}
