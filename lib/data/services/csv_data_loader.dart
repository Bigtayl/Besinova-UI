import 'dart:io';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/product.dart';

/// Service for loading product data from CSV files
class CsvDataLoader {
  /// Load products from CSV file
  static Future<List<Product>> loadProductsFromCsv() async {
    try {
      // Load CSV data from assets
      final String csvData =
          await rootBundle.loadString('assets/enriched_2025_05_21.csv');

      // Split by lines first to handle potential line ending issues
      List<String> lines = csvData.split('\n');

      if (lines.isEmpty) {
        return [];
      }

      // Get headers from first line
      String headerLine = lines[0].trim();
      List<String> headers =
          headerLine.split(',').map((h) => h.trim()).toList();

      // Validate headers
      List<String> requiredHeaders = [
        'category',
        'subcategory',
        'item_category',
        'name',
        'price',
        'market',
        'image_url',
        'calories',
        'protein',
        'carbs',
        'fat'
      ];
      for (String required in requiredHeaders) {
        if (!headers.contains(required)) {
          return [];
        }
      }

      // Convert data rows to products
      List<Product> products = [];
      int productId = 1;

      for (int i = 1; i < lines.length; i++) {
        try {
          String line = lines[i].trim();
          if (line.isEmpty) {
            continue;
          }

          // Parse CSV line manually to handle complex data
          List<String> values = _parseCsvLine(line);

          if (values.length < headers.length) {
            continue;
          }

          Map<String, dynamic> rowMap = {};
          for (int j = 0; j < headers.length; j++) {
            rowMap[headers[j]] = values[j];
          }

          // Validate required fields
          if (rowMap['name'] == null ||
              rowMap['name'].toString().trim().isEmpty) {
            continue;
          }

          // Create product from row data
          Product product = Product.fromCsvRow(rowMap, productId);
          products.add(product);
          productId++;
        } catch (e) {
          continue;
        }
      }

      return products;
    } catch (e) {
      return [];
    }
  }

  /// Parse a CSV line manually to handle complex data
  static List<String> _parseCsvLine(String line) {
    List<String> values = [];
    String currentValue = '';
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final c = line[i];

      if (c == '"') {
        inQuotes = !inQuotes;
      } else if (c == ',' && !inQuotes) {
        values.add(currentValue.trim());
        currentValue = '';
      } else {
        currentValue += c;
      }
    }

    // Add the last value
    values.add(currentValue.trim());

    return values;
  }

  /// Load products from a local file (for testing)
  static Future<List<Product>> loadProductsFromFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return [];
      }

      final String csvData = await file.readAsString();

      // Parse CSV
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvData);

      if (csvTable.isEmpty) {
        return [];
      }

      // Get headers (first row)
      List<String> headers =
          csvTable[0].map((header) => header.toString()).toList();

      // Convert rows to products
      List<Product> products = [];
      int productId = 1;

      for (int i = 1; i < csvTable.length; i++) {
        try {
          List<dynamic> row = csvTable[i];
          Map<String, dynamic> rowMap = {};

          // Create map from headers and values
          for (int j = 0; j < headers.length && j < row.length; j++) {
            rowMap[headers[j]] = row[j];
          }

          // Create product from row data
          Product product = Product.fromCsvRow(rowMap, productId);
          products.add(product);
          productId++;
        } catch (e) {
          continue;
        }
      }

      return products;
    } catch (e) {
      return [];
    }
  }

  /// Get sample products for testing (when CSV is not available)
  static List<Product> getSampleProducts() {
    return [
      Product(
        id: 1,
        name: "Domates 1kg",
        market: "Market A",
        price: 15.50,
        category: "Sebze",
        itemCategory: "Sebze",
        caloriesPer100g: 18,
        proteinPer100g: 0.9,
        carbsPer100g: 3.9,
        fatPer100g: 0.2,
        weightG: 1000,
        mainGroup: "vegetables",
        createdAt: DateTime.now(),
      ),
      Product(
        id: 2,
        name: "Tavuk Göğsü 1kg",
        market: "Market B",
        price: 45.00,
        category: "Et",
        itemCategory: "Et",
        caloriesPer100g: 165,
        proteinPer100g: 31,
        carbsPer100g: 0,
        fatPer100g: 3.6,
        weightG: 1000,
        mainGroup: "meat_fish",
        createdAt: DateTime.now(),
      ),
      Product(
        id: 3,
        name: "Pirinç 1kg",
        market: "Market C",
        price: 25.00,
        category: "Temel Gıda",
        itemCategory: "Temel Gıda",
        caloriesPer100g: 130,
        proteinPer100g: 2.7,
        carbsPer100g: 28,
        fatPer100g: 0.3,
        weightG: 1000,
        mainGroup: "grains",
        createdAt: DateTime.now(),
      ),
      Product(
        id: 4,
        name: "Süt 1L",
        market: "Market A",
        price: 12.50,
        category: "Süt Ürünleri",
        itemCategory: "Süt",
        caloriesPer100g: 42,
        proteinPer100g: 3.4,
        carbsPer100g: 5.0,
        fatPer100g: 1.0,
        weightG: 1000,
        mainGroup: "dairy",
        createdAt: DateTime.now(),
      ),
      Product(
        id: 5,
        name: "Elma 1kg",
        market: "Market B",
        price: 18.00,
        category: "Meyve",
        itemCategory: "Meyve",
        caloriesPer100g: 52,
        proteinPer100g: 0.3,
        carbsPer100g: 14,
        fatPer100g: 0.2,
        weightG: 1000,
        mainGroup: "fruits",
        createdAt: DateTime.now(),
      ),
    ];
  }
}
