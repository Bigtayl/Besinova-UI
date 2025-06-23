// nutrition_screen.dart
// Kullanıcıya besin önerileri sunacak ekran. Analizlerden gelen verilerle
// kişiselleştirilmiş besin önerileri ve makro değerleri gösterir.

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  String _searchQuery = '';
  late TabController _tabController;
  List<Product> _favorites = [];
  Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await FavoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
        _favoriteIds = favorites.map((p) => p.id).toSet();
      });
    } catch (e) {
      // Handle error silently or log to a proper logging service
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    try {
      final success = await FavoritesService.toggleFavorite(product);
      if (success) {
        await _loadFavorites(); // Reload favorites
      }
    } catch (e) {
      // Handle error silently or log to a proper logging service
    }
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return widget.products;
    }
    return widget.products
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Text(
                '${widget.products.length} ürün bulundu',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
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
            ],
          ),
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
          // Arama kartı
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
                      _searchQuery = value;
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Ürün listesi
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
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
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final profile = snapshot.data!;
        final weight = _parseDouble(profile['weight'], 70.0);
        final height = _parseDouble(profile['height'], 170.0);
        final age = int.tryParse(profile['age']?.toString() ?? '') ?? 25;
        final gender = (profile['gender'] as String?) ?? 'Erkek';
        final activityLevel = (profile['activityLevel'] as String?) ?? 'Orta';

        // Makro hesaplamaları
        double bmr;
        if (gender.toLowerCase() == 'erkek') {
          bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
        } else {
          bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
        }

        final activityMultipliers = {
          'Düşük': 1.2,
          'Orta': 1.55,
          'Yüksek': 1.725,
        };

        final tdee = bmr * (activityMultipliers[activityLevel] ?? 1.55);
        final protein = weight * 2.0; // 2g/kg
        final fat = tdee * 0.25 / 9; // %25 yağ
        final carb =
            (tdee - (protein * 4) - (fat * 9)) / 4; // Kalan karbonhidrat

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Makro özeti kartı
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
                          'Günlük Hedefler',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildProgressBar('Protein', 45, protein, nutritionColor),
                    const SizedBox(height: 12),
                    _buildProgressBar(
                        'Karbonhidrat', 120, carb, nutritionColor),
                    const SizedBox(height: 12),
                    _buildProgressBar('Yağ', 35, fat, nutritionColor),
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
    if (_favorites.isEmpty) {
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
                _tabController.animateTo(0); // Go to recommendations tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: nutritionColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favori Besinleriniz (${_favorites.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final product = _favorites[index];
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

  Widget _buildProductCard(Product product, Color color) {
    final isFavorite = _favoriteIds.contains(product.id);

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image and basic info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: color.withValues(alpha: 0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: color.withValues(alpha: 0.1),
                      child: Icon(Icons.image_not_supported,
                          color: color.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name - made larger
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increased font size
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Market and price
                      Text(
                        '${product.market} • ${product.price.toStringAsFixed(2)} TL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Nutrition info if available
                      if (product.caloriesPer100g != null)
                        Text(
                          '${product.caloriesPer100g!.toStringAsFixed(0)} kcal/100g',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Heart button (favorite)
                GestureDetector(
                  onTap: () => _toggleFavorite(product),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isFavorite
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isFavorite
                            ? Colors.red.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Add to list button - made longer to fill space
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Favorilere ekleme işlemi
                      await _toggleFavorite(product);

                      // Bildirim göster
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} favorilere eklendi'),
                            backgroundColor: color,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Listeme Ekle',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
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
  State<_AnalysisResultsExpansionPanel> createState() =>
      _AnalysisResultsExpansionPanelState();
}

class _AnalysisResultsExpansionPanelState
    extends State<_AnalysisResultsExpansionPanel> {
  Future<Map<String, dynamic>> _getSelectedProfile() async {
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

  double _calculateBMI(dynamic weight, dynamic height) {
    final w = double.tryParse(weight?.toString() ?? '0') ?? 0;
    final h = double.tryParse(height?.toString() ?? '0') ?? 0;
    if (w > 0 && h > 0) {
      final hM = h / 100;
      return w / (hM * hM);
    }
    return 0;
  }

  double _calculateBMR(
      dynamic weight, dynamic height, dynamic age, dynamic gender) {
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
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final profile = snapshot.data!;
        final weight =
            double.tryParse(profile['weight']?.toString() ?? '0') ?? 0;
        final height =
            double.tryParse(profile['height']?.toString() ?? '0') ?? 0;
        final age = int.tryParse(profile['age']?.toString() ?? '0') ?? 0;
        final gender = profile['gender']?.toString() ?? '';

        final bmi = _calculateBMI(weight, height);
        final bmr = _calculateBMR(weight, height, age, gender);

        return ExpansionTile(
          title: const Text(
            'Vücut Analizi Sonuçları',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAnalysisResult('BMI', bmi.toStringAsFixed(1)),
                      _buildAnalysisResult('BMR', bmr.toStringAsFixed(0)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAnalysisResult(
                          'Kilo', '${weight.toStringAsFixed(1)} kg'),
                      _buildAnalysisResult(
                          'Boy', '${height.toStringAsFixed(0)} cm'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisResult(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFFFFB86C),
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
