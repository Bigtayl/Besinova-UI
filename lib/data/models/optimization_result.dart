import 'shopping_result.dart';
import 'shopping_item.dart';

/// OptimizationResult model combining shopping results and items
class OptimizationResult {
  const OptimizationResult({
    required this.shoppingResult,
    required this.shoppingItems,
  });

  final ShoppingResult shoppingResult;
  final List<ShoppingItem> shoppingItems;

  /// Creates an OptimizationResult from JSON data
  factory OptimizationResult.fromJson(Map<String, dynamic> json) => OptimizationResult(
        shoppingResult: ShoppingResult.fromJson(json['shoppingResult'] as Map<String, dynamic>),
        shoppingItems: (json['shoppingItems'] as List<dynamic>)
            .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  /// Converts OptimizationResult to JSON data
  Map<String, dynamic> toJson() => {
        'shoppingResult': shoppingResult.toJson(),
        'shoppingItems': shoppingItems.map((item) => item.toJson()).toList(),
      };

  /// Creates a copy of this OptimizationResult with updated fields
  OptimizationResult copyWith({
    ShoppingResult? shoppingResult,
    List<ShoppingItem>? shoppingItems,
  }) =>
      OptimizationResult(
        shoppingResult: shoppingResult ?? this.shoppingResult,
        shoppingItems: shoppingItems ?? this.shoppingItems,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OptimizationResult && other.shoppingResult == shoppingResult;

  @override
  int get hashCode => shoppingResult.hashCode;

  @override
  String toString() =>
      'OptimizationResult(shoppingResult: $shoppingResult, itemsCount: ${shoppingItems.length})';
} 