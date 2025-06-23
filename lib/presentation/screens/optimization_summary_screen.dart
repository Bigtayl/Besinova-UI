// optimization_summary_screen.dart
// Optimizasyon sonuçlarını gösteren ekran. Kullanıcının beslenme hedeflerine göre
// optimize edilmiş alışveriş listesinin özetini ve detaylarını gösterir.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/optimization_provider.dart';
import '../providers/user_provider.dart';
import '../../data/models/shopping_item.dart';

/// Optimizasyon özeti ekranı
class OptimizationSummaryScreen extends StatelessWidget {
  const OptimizationSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color midnightBlue = Color(0xFF2C3E50);
    const Color deepFern = Color(0xFF52796F);
    const Color summaryColor = Color(0xFF4ECDC4);

    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: summaryColor.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, summaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Optimizasyon Özeti',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [summaryColor.withValues(alpha: 0.8), midnightBlue],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Consumer<OptimizationProvider>(
            builder: (context, optimizationProvider, child) {
              if (optimizationProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: summaryColor,
                  ),
                );
              }

              if (optimizationProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: summaryColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Optimizasyon hatası',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        optimizationProvider.error!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final result = optimizationProvider.optimizationResult;
              if (result == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: summaryColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Henüz optimizasyon yapılmadı',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Alışveriş listesi ekranından optimizasyonu başlatın',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(result, optimizationProvider),
                    const SizedBox(height: 20),
                    _buildNutritionCard(result),
                    const SizedBox(height: 20),
                    _buildCategoryBreakdown(optimizationProvider),
                    const SizedBox(height: 20),
                    _buildBudgetAnalysis(context, optimizationProvider),
                    const SizedBox(height: 20),
                    _buildRecommendationsCard(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(dynamic result, OptimizationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF4ECDC4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Optimizasyon Özeti',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Toplam Ürün',
                  '${provider.shoppingItems.length}',
                  Icons.shopping_basket,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Toplam Maliyet',
                  '${provider.totalCost.toStringAsFixed(2)} ₺',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Toplam Kalori',
                  '${provider.totalCalories.toStringAsFixed(0)} kcal',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Gün Sayısı',
                  '${result.shoppingResult.days} gün',
                  Icons.calendar_today,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(dynamic result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_heart,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Beslenme Değerleri',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildNutritionBar(
              'Protein', result.shoppingResult.totalProtein, Colors.green, 'g'),
          const SizedBox(height: 12),
          _buildNutritionBar('Karbonhidrat', result.shoppingResult.totalCarbs,
              Colors.blue, 'g'),
          const SizedBox(height: 12),
          _buildNutritionBar(
              'Yağ', result.shoppingResult.totalFat, Colors.orange, 'g'),
        ],
      ),
    );
  }

  Widget _buildNutritionBar(
      String label, double value, Color color, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.7, // This would be calculated based on daily requirements
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(OptimizationProvider provider) {
    final categoryCounts = provider.categoryCounts;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Kategori Dağılımı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...categoryCounts.entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: entry.value,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(entry.key),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key} (${entry.value})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'meyve & sebze':
        return Colors.green;
      case 'süt & kahvaltı':
        return Colors.blue;
      case 'et & tavuk':
        return Colors.red;
      case 'temel gıda':
        return Colors.orange;
      case 'bakliyat':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBudgetAnalysis(
      BuildContext context, OptimizationProvider provider) {
    final userProvider = context.read<UserProvider>();
    final budget = userProvider.user?.budget ?? 1000.0;
    final utilization = provider.getBudgetUtilization(budget);
    final remaining = provider.getBudgetRemaining(budget);
    final isExceeded = provider.isBudgetExceeded(budget);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: isExceeded ? Colors.red : Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Bütçe Analizi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBudgetItem(
                  'Bütçe',
                  '${budget.toStringAsFixed(2)} ₺',
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBudgetItem(
                  'Harcanan',
                  '${provider.totalCost.toStringAsFixed(2)} ₺',
                  isExceeded ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBudgetItem(
                  'Kalan',
                  '${remaining.toStringAsFixed(2)} ₺',
                  remaining >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBudgetItem(
                  'Kullanım',
                  '%${utilization.toStringAsFixed(1)}',
                  utilization > 100 ? Colors.red : Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: utilization / 100,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              utilization > 100 ? Colors.red : Colors.green,
            ),
            minHeight: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.teal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Öneriler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecommendationItem(
            'Düzenli alışveriş yapın',
            'Haftalık planlama ile daha iyi fiyatlar elde edebilirsiniz.',
            Icons.schedule,
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            'Mevsimsel ürünleri tercih edin',
            'Mevsiminde olan sebze ve meyveler daha uygun fiyatlıdır.',
            Icons.eco,
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            'Toplu alım yapın',
            'Uzun süre dayanabilen ürünleri toplu alarak tasarruf edin.',
            Icons.shopping_cart,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
      String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.teal,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
