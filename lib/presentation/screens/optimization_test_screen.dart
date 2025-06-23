import 'package:flutter/material.dart';
import '../../data/services/optimization_service.dart';
import '../../data/models/user.dart';
import '../../data/models/optimization_result.dart';

/// Test screen for verifying local optimization functionality
class OptimizationTestScreen extends StatefulWidget {
  const OptimizationTestScreen({super.key});

  @override
  State<OptimizationTestScreen> createState() => _OptimizationTestScreenState();
}

class _OptimizationTestScreenState extends State<OptimizationTestScreen> {
  bool _isLoading = false;
  OptimizationResult? _result;
  String? _error;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _stats = OptimizationService.getOptimizationStats();
    });
  }

  Future<void> _runOptimization() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      // Create a test user
      User testUser = User(
        name: "Test User",
        email: "test@example.com",
        height: 175.0,
        weight: 70.0,
        age: 30,
        gender: "male",
        activityLevel: "moderately active",
        goal: "maintain weight",
        avatar: "default",
        loginCount: 1,
        lastLogin: DateTime.now().toIso8601String(),
        completedGoals: 0,
        budget: 500.0,
        notificationCount: 0,
      );

      // Run optimization
      OptimizationResult? result = await OptimizationService.optimizeShopping(
        user: testUser,
        days: 30,
      );

      setState(() {
        _isLoading = false;
        if (result != null) {
          _result = result;
        } else {
          _error = "Optimization failed";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimization Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          OptimizationService.isReady() 
                            ? Icons.check_circle 
                            : Icons.error,
                          color: OptimizationService.isReady() 
                            ? Colors.green 
                            : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          OptimizationService.isReady() 
                            ? 'Ready' 
                            : 'Not Ready',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics
            if (_stats != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Statistics',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Total Products: ${_stats!['total_products']}'),
                      Text('Average Price: ${_stats!['price_range']['avg'].toStringAsFixed(2)} TL'),
                      Text('Average Calories: ${_stats!['calories_range']['avg'].toStringAsFixed(0)} kcal'),
                      const SizedBox(height: 8),
                      Text(
                        'Categories:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ...(_stats!['categories'] as Map<String, dynamic>).entries.map(
                        (entry) => Text('  ${entry.key}: ${entry.value}'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Test Button
            ElevatedButton(
              onPressed: _isLoading ? null : _runOptimization,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Run Optimization Test'),
            ),
            const SizedBox(height: 16),

            // Results
            if (_result != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Optimization Results',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Total Cost: ${_result!.shoppingResult.totalCost.toStringAsFixed(2)} TL'),
                      Text('Budget Usage: ${_result!.shoppingResult.budgetUsage.toStringAsFixed(1)}%'),
                      Text('Total Items: ${_result!.shoppingResult.totalItems}'),
                      Text('Total Weight: ${(_result!.shoppingResult.totalWeight / 1000).toStringAsFixed(1)} kg'),
                      Text('Total Calories: ${_result!.shoppingResult.calories.toStringAsFixed(0)} kcal'),
                      Text('Total Protein: ${_result!.shoppingResult.protein.toStringAsFixed(0)} g'),
                      Text('Total Fat: ${_result!.shoppingResult.fat.toStringAsFixed(0)} g'),
                      Text('Total Carbs: ${_result!.shoppingResult.carbs.toStringAsFixed(0)} g'),
                      const SizedBox(height: 16),
                      Text(
                        'Selected Products (${_result!.shoppingItems.length}):',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._result!.shoppingItems.take(10).map((item) => 
                        ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.quantity}x - ${item.totalPrice.toStringAsFixed(2)} TL'),
                          trailing: Text(item.category),
                        ),
                      ),
                      if (_result!.shoppingItems.length > 10)
                        Text('... and ${_result!.shoppingItems.length - 10} more items'),
                    ],
                  ),
                ),
              ),
            ],

            // Error
            if (_error != null) ...[
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 