// nutrition_screen.dart
// Kullanıcıya besin önerileri sunacak ekran. Analizlerden gelen verilerle
// kişiselleştirilmiş besin önerileri ve makro değerleri gösterir.

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../presentation/presentation.dart';
import 'settings_screen.dart';

/// Besin önerileri ekranı: Kişiselleştirilmiş besin önerileri ve makro değerleri.
class NutritionScreen extends StatefulWidget {
  final Color iconColor;
  final String detailText;
  final List<Product> products;

  const NutritionScreen({
    super.key,
    this.iconColor = const Color(0xFFFFB86C), // Ana sayfa buton rengi
    this.detailText = 'Sağlıklı beslenme için öneriler ve ipuçları!',
    required this.products,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Tümü';
  List<String> categories = ['Tümü', 'Protein', 'Karbonhidrat', 'Yağ'];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    const Color midnightBlue = Color(0xFF2C3E50);
    final Color nutritionColor = widget.iconColor; // Turuncu renk
    final Color nutritionLight = nutritionColor.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: nutritionColor.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, nutritionColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Besin Önerileri',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 1.2,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Öneriler'),
            Tab(text: 'Makrolar'),
            Tab(text: 'Favoriler'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [nutritionColor.withValues(alpha: 0.8), midnightBlue],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Dekoratif arka plan daireleri
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nutritionLight,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nutritionLight,
                  ),
                ),
              ),
              // Ana içerik
              TabBarView(
                controller: _tabController,
                children: [
                  // Öneriler sekmesi
                  _buildRecommendationsTab(nutritionColor, nutritionLight),
                  // Makrolar sekmesi
                  _buildMacrosTab(nutritionColor, nutritionLight),
                  // Favoriler sekmesi
                  _buildFavoritesTab(nutritionColor, nutritionLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsTab(Color nutritionColor, Color nutritionLight) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arama ve kategori kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: nutritionColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: nutritionLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: nutritionColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: nutritionColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.search,
                        color: nutritionColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Besin Ara',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Besin ara...',
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    prefixIcon: Icon(Icons.search, color: nutritionColor),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: nutritionColor.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: nutritionColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategory == categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            categories[index],
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF2C3E50)
                                  : const Color(0xFF222222),
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = categories[index];
                            });
                          },
                          backgroundColor: isSelected
                              ? nutritionColor
                              : const Color(0xFFECECEC),
                          selectedColor: nutritionColor,
                          side: BorderSide(
                            color: isSelected ? nutritionColor : Colors.black.withOpacity(0.08),
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Açılır-Kapanır Analiz Sonuçları Paneli
          _AnalysisResultsExpansionPanel(),
          const SizedBox(height: 16),
          // Bütçe optimizasyonu kartı
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final budget = userProvider.budget;
              final optimizationService = BudgetOptimizationService();
              final optimizedProducts = budget > 0
                  ? optimizationService.optimizeProductsForBudget(
                      products: widget.products,
                      budget: budget,
                    )
                  : <Product>[];
              final budgetUsage = budget > 0
                  ? optimizationService.calculateBudgetUsage(
                      selectedProducts: optimizedProducts,
                      budget: budget,
                    )
                  : 0.0;
              final suggestions = budget > 0
                  ? optimizationService.generateBudgetSuggestions(
                      budget: budget,
                      selectedProducts: optimizedProducts,
                    )
                  : <String>[];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: nutritionColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF50FA7B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF50FA7B)
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFF50FA7B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Bütçe Optimizasyonu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (budget > 0) ...[
                      // Bütçe bilgisi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Aylık Bütçe:',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₺${budget.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Bütçe kullanım oranı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kullanım:',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${budgetUsage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: budgetUsage > 100
                                  ? Colors.red
                                  : budgetUsage > 80
                                      ? const Color(0xFFFFB86C)
                                      : const Color(0xFF50FA7B),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Öneriler
                      if (suggestions.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF50FA7B)
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF50FA7B),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  suggestions.first,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Optimize edilmiş ürün sayısı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Önerilen Ürün:',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${optimizedProducts.length} ürün',
                            style: const TextStyle(
                              color: Color(0xFF50FA7B),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Bütçe belirlenmemiş durumu
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bütçe belirlenmedi. Ayarlar sayfasından bütçenizi belirleyerek besin önerilerinizi optimize edebilirsiniz.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Bütçe ayarlama butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        label: Text(
                            budget > 0 ? 'Bütçeyi Düzenle' : 'Bütçe Belirle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF50FA7B).withValues(alpha: 0.2),
                          foregroundColor: const Color(0xFF50FA7B),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: const Color(0xFF50FA7B)
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Ürün listesi
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildProductCard(product, nutritionColor),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosTab(Color nutritionColor, Color nutritionLight) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSelectedProfileMacros(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bir hata oluştu: ${snapshot.error}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Analizlerim ekranından bir profil oluşturup analiz yapmalısın.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final macros = snapshot.data!;
        final tdee = _parseDouble(macros['tdee'], 2000);
        final protein = _parseDouble(macros['protein'], 120);
        final carb = _parseDouble(macros['carb'], 250);
        final fat = _parseDouble(macros['fat'], 45);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Makro besin özeti kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: nutritionColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: nutritionLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: nutritionColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: nutritionColor.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.monitor_weight_outlined,
                            color: nutritionColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Makro Besin Özeti',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroNutrient(
                            'Protein',
                            '${protein.toStringAsFixed(0)}g',
                            Icons.fitness_center,
                            nutritionColor),
                        _buildMacroNutrient(
                            'Karbonhidrat',
                            '${carb.toStringAsFixed(0)}g',
                            Icons.grain,
                            nutritionColor),
                        _buildMacroNutrient('Yağ', '${fat.toStringAsFixed(0)}g',
                            Icons.water_drop, nutritionColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Günlük hedef kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: nutritionColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: nutritionLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: nutritionColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: nutritionColor.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.track_changes,
                            color: nutritionColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Günlük Hedef',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildProgressBar('Kalori', tdee, tdee, nutritionColor),
                    const SizedBox(height: 12),
                    _buildProgressBar(
                        'Protein', protein, protein, nutritionColor),
                    const SizedBox(height: 12),
                    _buildProgressBar(
                        'Karbonhidrat', carb, carb, nutritionColor),
                    const SizedBox(height: 12),
                    _buildProgressBar('Yağ', fat, fat, nutritionColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  Future<Map<String, dynamic>> _getSelectedProfileMacros() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesString = prefs.getString('profiles');
    final int? selectedIndex = prefs.getInt('selectedProfileIndex');
    if (profilesString != null && selectedIndex != null) {
      final List<dynamic> decoded = json.decode(profilesString);
      if (selectedIndex >= 0 && selectedIndex < decoded.length) {
        final Map<String, dynamic> profile =
            Map<String, dynamic>.from(decoded[selectedIndex]);
        return profile;
      }
    }
    return {};
  }

  Widget _buildFavoritesTab(Color nutritionColor, Color nutritionLight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 64,
            color: nutritionColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz favori besin eklenmemiş',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Favori ekleme işlemi
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: nutritionColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Favori Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.imageUrl ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: color.withValues(alpha: 0.1),
              child: Icon(Icons.image_not_supported,
                  color: color.withValues(alpha: 0.5)),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${product.market} • ${product.price.toStringAsFixed(2)} TL',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white70),
              onPressed: () {
                // Favori ekleme işlemi
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Sepete ekleme işlemi
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Listeme Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroNutrient(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
      String label, double current, double target, Color color) {
    final progress = current / target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            Text(
              '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// Açılır-kapanır analiz paneli widget'ı
class _AnalysisResultsExpansionPanel extends StatefulWidget {
  @override
  State<_AnalysisResultsExpansionPanel> createState() => _AnalysisResultsExpansionPanelState();
}

class _AnalysisResultsExpansionPanelState extends State<_AnalysisResultsExpansionPanel> {
  Future<Map<String, dynamic>> _getSelectedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesString = prefs.getString('profiles');
    final int? selectedIndex = prefs.getInt('selectedProfileIndex');
    if (profilesString != null && selectedIndex != null) {
      final List<dynamic> decoded = json.decode(profilesString);
      if (selectedIndex >= 0 && selectedIndex < decoded.length) {
        final Map<String, dynamic> profile = Map<String, dynamic>.from(decoded[selectedIndex]);
        return profile;
      }
    }
    return {};
  }

  double _calculateBMI(dynamic weight, dynamic height) {
    final w = double.tryParse(weight?.toString() ?? '0') ?? 0;
    final h = double.tryParse(height?.toString() ?? '0') ?? 0;
    if (w > 0 && h > 0) {
      final hM = h / 100;
      return w / (hM * hM);
    }
    return 0;
  }

  double _calculateBMR(dynamic weight, dynamic height, dynamic age, dynamic gender) {
    final w = double.tryParse(weight?.toString() ?? '0') ?? 0;
    final h = double.tryParse(height?.toString() ?? '0') ?? 0;
    final a = int.tryParse(age?.toString() ?? '0') ?? 0;
    final g = (gender?.toString() ?? '').toLowerCase();
    if (w > 0 && h > 0 && a > 0) {
      if (g == 'erkek') {
        return 10 * w + 6.25 * h - 5 * a + 5;
      } else {
        return 10 * w + 6.25 * h - 5 * a - 161;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSelectedProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final profile = snapshot.data;
        double bmi = 0;
        double bmr = 0;
        if (profile != null && profile.isNotEmpty) {
          bmi = double.tryParse(profile['bmi']?.toString() ?? '') ??
                _calculateBMI(profile['weight'], profile['height']);
          bmr = double.tryParse(profile['bmr']?.toString() ?? '') ??
                _calculateBMR(profile['weight'], profile['height'], profile['age'], profile['gender']);
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFB86C).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB86C).withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Row(
              children: [
                Icon(Icons.analytics_outlined, color: const Color(0xFFFFB86C), size: 26),
                const SizedBox(width: 10),
                Text('Analiz Sonuçların', style: TextStyle(color: const Color(0xFFFFB86C), fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            children: [
              if (profile == null || profile.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: const Color(0xFFFFB86C), size: 24),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Analizlerim ekranından bir profil oluşturup analiz yapmalısın. Sonuçlar burada görünecek.',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 10,
                    children: [
                      _buildAnalysisInfo('İsim', profile['name'] ?? '-'),
                      _buildAnalysisInfo('Yaş', profile['age']?.toString() ?? '-'),
                      _buildAnalysisInfo('Cinsiyet', profile['gender'] ?? '-'),
                      _buildAnalysisInfo('Boy', profile['height']?.toString() ?? '-'),
                      _buildAnalysisInfo('Kilo', profile['weight']?.toString() ?? '-'),
                      _buildAnalysisInfo('Hedef', profile['purpose'] ?? '-'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAnalysisResult('BMI', bmi > 0 ? bmi.toStringAsFixed(1) : '-'),
                      _buildAnalysisResult('BMR', bmr > 0 ? bmr.toStringAsFixed(0) : '-'),
                      _buildAnalysisResult('TDEE', profile['tdee'] ?? ''),
                    ],
                  ),
                ),
                if (profile['tdee'] != null && profile['tdee'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 12),
                    child: Text('Günlük kalori ihtiyacın: ${profile['tdee'].toString().split('.')[0]} kcal',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalysisInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB86C).withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$label: $value', style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }

  Widget _buildAnalysisResult(String label, dynamic value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFFFB86C), fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value != null && value.toString().isNotEmpty ? value.toString().split('.')[0] : '-',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
