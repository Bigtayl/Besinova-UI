// home_screen.dart
// Uygulamanın ana ekranı. Kullanıcıya selam, ana fonksiyonlara hızlı erişim, animasyonlu grid kartlar ve alt gezinme çubuğu içerir.
// AppBar'da bildirimler ve profil avatarı gösterilir. Navigasyon ve ekran geçişleri burada yönetilir.

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'localization.dart';
import 'models/product.dart';

/// Ana ekran widget'ı. Kullanıcıya selam verir ve ana fonksiyonlara erişim sağlar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Alt menüde seçili olan index
  bool _showedOnboarding = false; // Onboarding gösterildi mi?

  // Örnek ürün listesi
  final List<Product> _productList = [
    Product(
      name: 'Tavuk Göğsü',
      market: 'Migros',
      price: 89.90,
      imageUrl: 'https://example.com/tavuk.jpg',
    ),
    Product(
      name: 'Somon Balığı',
      market: 'Carrefoursa',
      price: 129.90,
      imageUrl: 'https://example.com/somon.jpg',
    ),
    Product(
      name: 'Yulaf Ezmesi',
      market: 'BİM',
      price: 45.90,
      imageUrl: 'https://example.com/yulaf.jpg',
    ),
  ];

  // Sayfaları tutan liste
  late final List<Widget> _pages = [
    HomeContent(productList: _productList), // Ana sayfa içeriği
    const ShoppingListScreen(),
    NutritionScreen(
      iconColor: const Color(0xFFFFB86C),
      detailText: 'Sağlıklı beslenme için öneriler ve ipuçları!',
      products: _productList,
    ),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Uygulama ilk açıldığında onboarding göster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOnboardingIfFirstTime();
    });
  }

  /// Uygulama ilk açıldığında kullanıcıya hoş geldin mesajı gösterir.
  Future<void> _showOnboardingIfFirstTime() async {
    if (!_showedOnboarding) {
      setState(() {
        _showedOnboarding = true;
      });
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t("Hoş geldin!")),
          content: Text(
            t(
              "Besinova ile sağlıklı yaşam yolculuğuna başla! Ana ekrandaki butonlardan alışveriş listeni, besin önerilerini, analizlerini ve ayarları keşfedebilirsin. Alt menüden hızlıca geçiş yapabilirsin.",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t("Başla")),
            ),
          ],
        ),
      );
    }
  }

  /// Alt menüde bir sekmeye tıklanınca ilgili ekrana geçiş yapar.
  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<UserProvider>(context).name;
    // Tema renkleri
    const Color tropicalLime = Color(0xFFA3EBB1);
    const Color deepFern = Color(0xFF52796F);
    const Color midnightBlue = Color(0xFF2C3E50);
    const Color whiteSmoke = Color(0xFFF5F5F5);
    const Color oliveShadow = Color(0xFF6B705C);

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: midnightBlue,
        // Uygulamanın üst kısmı: AppBar
        appBar: _selectedIndex == 0
            ? AppBar(
                backgroundColor: deepFern.withOpacity(0.95),
                elevation: 0,
                centerTitle: true,
                title: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [tropicalLime, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Besinova',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                actions: [
                  // Bildirim ikonu
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return IconButton(
                          onPressed: () {
                            // Bildirimler sayfasına git (gelecekte eklenebilir)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bildirimler yakında eklenecek!'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                              // Bildirim sayısı badge'i (sadece bildirim varsa göster)
                              if (userProvider.notificationCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      userProvider.notificationCount > 99
                                          ? '99+'
                                          : userProvider.notificationCount
                                              .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Profil ikonu
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return GestureDetector(
                          onTap: () {
                            // Profil sayfasına git
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: userProvider.avatar.isNotEmpty &&
                                      userProvider.avatar.length == 2 &&
                                      userProvider.avatar.codeUnitAt(0) > 255
                                  ? Text(
                                      userProvider.avatar,
                                      style: const TextStyle(fontSize: 20),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : null,
        // Ana içerik
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        // Alt gezinme çubuğu (BottomNavigationBar)
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: deepFern,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Ana Sayfa'),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag),
                label: 'Alışveriş',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fastfood),
                label: 'Besinler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analiz',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ana sayfa içeriği widget'ı
class HomeContent extends StatelessWidget {
  final List<Product> productList;

  const HomeContent({
    super.key,
    required this.productList,
  });

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<UserProvider>(context).name;
    // Tema renkleri
    const Color tropicalLime = Color(0xFFA3EBB1);
    const Color deepFern = Color(0xFF52796F);
    const Color midnightBlue = Color(0xFF2C3E50);
    const Color whiteSmoke = Color(0xFFF5F5F5);
    const Color oliveShadow = Color(0xFF6B705C);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [deepFern.withOpacity(0.8), midnightBlue],
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
                  color: tropicalLime.withOpacity(0.1),
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
                  color: deepFern.withOpacity(0.1),
                ),
              ),
            ),
            // Kullanıcıya selam ve motivasyon kartı
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Merhaba, $userName!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bugün sağlıklı beslenmeye devam edelim!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Ana fonksiyonlara erişim için animasyonlu grid kartlar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: whiteSmoke.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: oliveShadow.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Arka plan desenleri (dekoratif daireler, noktalar, dalgalar)
                          Positioned(
                            right: 20,
                            top: 20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    const Color(0xFFFF6B6B).withOpacity(0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 20,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    const Color(0xFFFFB86C).withOpacity(0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            bottom: 60,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    const Color(0xFF50FA7B).withOpacity(0.08),
                              ),
                            ),
                          ),
                          // Noktalı desen
                          Positioned.fill(
                            child: CustomPaint(
                              painter: DotsPatternPainter(
                                color: Colors.grey.withOpacity(0.15),
                                dotRadius: 1.5,
                                spacing: 20,
                              ),
                            ),
                          ),
                          // Dalgalı çizgiler
                          Positioned.fill(
                            child: CustomPaint(
                              painter: WavePatternPainter(
                                color: Colors.grey.withOpacity(0.15),
                                waveHeight: 20,
                                waveWidth: 100,
                              ),
                            ),
                          ),
                          // Ana içerik: animasyonlu grid kartlar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            child: Center(
                              child: AnimationLimiter(
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.75,
                                  padding: const EdgeInsets.all(12),
                                  children:
                                      AnimationConfiguration.toStaggeredList(
                                    duration: const Duration(milliseconds: 375),
                                    childAnimationBuilder: (widget) =>
                                        SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: widget,
                                      ),
                                    ),
                                    children: [
                                      // Ana fonksiyon kartları
                                      _buildHomeCard(
                                        icon: Icons.shopping_cart_outlined,
                                        title: 'Alışveriş\nListem',
                                        subtitle: 'Alışveriş listeni\nyönet',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ShoppingListScreen()),
                                          );
                                        },
                                        iconColor: const Color(0xFFFF6B6B),
                                        iconBackgroundColor:
                                            const Color(0xFFFF6B6B)
                                                .withOpacity(0.15),
                                      ),
                                      _buildHomeCard(
                                        icon: Icons.restaurant_menu_outlined,
                                        title: 'Besin\nÖnerileri',
                                        subtitle: 'Sağlıklı\nbeslenme',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => NutritionScreen(
                                                iconColor:
                                                    const Color(0xFFFFB86C),
                                                detailText:
                                                    'Sağlıklı beslenme için öneriler ve ipuçları!',
                                                products: productList,
                                              ),
                                            ),
                                          );
                                        },
                                        iconColor: const Color(0xFFFFB86C),
                                        iconBackgroundColor:
                                            const Color(0xFFFFB86C)
                                                .withOpacity(0.15),
                                      ),
                                      _buildHomeCard(
                                        icon: Icons.analytics_outlined,
                                        title: 'Analizlerim',
                                        subtitle: 'Vücut analizi\nve öneriler',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const AnalyticsScreen()),
                                          );
                                        },
                                        iconColor: const Color(0xFF50FA7B),
                                        iconBackgroundColor:
                                            const Color(0xFF50FA7B)
                                                .withOpacity(0.15),
                                      ),
                                      _buildHomeCard(
                                        icon: Icons.settings_outlined,
                                        title: 'Ayarlar',
                                        subtitle: 'Uygulama\nayarları',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const SettingsScreen()),
                                          );
                                        },
                                        iconColor: const Color(0xFFBD93F9),
                                        iconBackgroundColor:
                                            const Color(0xFFBD93F9)
                                                .withOpacity(0.15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Alt bilgi
                  const Text(
                    'Besinova v1.0.0 • Sağlıklı yaşa 💚',
                    style: TextStyle(fontSize: 13, color: Color(0xFFFFE0B2)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ana ekrandaki fonksiyon kartlarını oluşturan yardımcı fonksiyon.
  Widget _buildHomeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
    required Color iconBackgroundColor,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white.withOpacity(0.9)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Arka plan için noktalı desen çizen yardımcı painter.
class DotsPatternPainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  DotsPatternPainter({
    required this.color,
    required this.dotRadius,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Arka plan için dalgalı çizgi deseni çizen yardımcı painter.
class WavePatternPainter extends CustomPainter {
  final Color color;
  final double waveHeight;
  final double waveWidth;

  WavePatternPainter({
    required this.color,
    required this.waveHeight,
    required this.waveWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    var y = size.height / 2;

    path.moveTo(0, y);
    for (double x = 0; x < size.width; x += waveWidth) {
      path.quadraticBezierTo(
        x + waveWidth / 2,
        y + waveHeight,
        x + waveWidth,
        y,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
