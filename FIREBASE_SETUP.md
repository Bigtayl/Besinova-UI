# Firebase Authentication Kurulum Rehberi

Bu rehber, Besinova uygulamasına Firebase Authentication eklemek için adım adım talimatları içerir.

## 1. Firebase Console'da Proje Oluşturma

### Adım 1: Firebase Console'a Git
- https://console.firebase.google.com adresine git
- Google hesabınla giriş yap

### Adım 2: Yeni Proje Oluştur
- "Proje Ekle" butonuna tıkla
- Proje adını "besinova-app" olarak gir
- Google Analytics'i etkinleştir (isteğe bağlı)
- "Proje Oluştur" butonuna tıkla

### Adım 3: Android Uygulaması Ekle
- Proje ana sayfasında Android ikonuna tıkla
- Android paket adını gir: `com.example.besinova`
- Uygulama takma adını gir: "Besinova"
- "Uygulamayı Kaydet" butonuna tıkla

### Adım 4: google-services.json Dosyasını İndir
- İndirilen google-services.json dosyasını `android/app/` klasörüne kopyala
- Mevcut dosyayı değiştir

## 2. Flutter Dependencies Ekleme

### Adım 1: pubspec.yaml Dosyasını Düzenle
pubspec.yaml dosyasına şu satırları ekle:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
```

### Adım 2: Dependencies'leri Yükle
Terminal'de şu komutu çalıştır:
```bash
flutter pub get
```

## 3. Firebase'i Uygulamaya Entegre Etme

### Adım 1: main.dart Dosyasını Düzenle
main.dart dosyasının başına şu import'ları ekle:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
```

### Adım 2: Firebase'i Başlat
main() fonksiyonunu şu şekilde güncelle:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlat
  await Firebase.initializeApp();
  
  // Diğer başlatma kodları...
  runApp(const BesinovaApp());
}
```

## 4. Authentication Servisi Oluşturma

### Adım 1: Yeni Dosya Oluştur
`lib/data/services/firebase_auth_service.dart` dosyasını oluştur:

```dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı durumunu dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/şifre ile kayıt ol
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Kayıt hatası: $e');
      return null;
    }
  }

  // Email/şifre ile giriş yap
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Giriş hatası: $e');
      return null;
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;
}
```

## 5. Authentication Provider Oluşturma

### Adım 1: Yeni Provider Dosyası Oluştur
`lib/presentation/providers/auth_provider.dart` dosyasını oluştur:

```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signUpWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
```

## 6. Provider'ı main.dart'a Ekleme

### Adım 1: Import Ekle
main.dart dosyasına şu import'u ekle:

```dart
import 'presentation/providers/auth_provider.dart';
```

### Adım 2: Provider'ı Ekle
MultiProvider listesine AuthProvider'ı ekle:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()..loadUserData()),
    ChangeNotifierProvider(create: (_) => OptimizationProvider()),
  ],
  child: const _BesinovaAppContent(),
)
```

## 7. Giriş/Kayıt Ekranlarını Güncelleme

### Adım 1: signin_screen.dart'ı Güncelle
Provider'ı kullanarak Firebase authentication ekle:

```dart
// Provider'dan AuthProvider'ı al
final authProvider = Provider.of<AuthProvider>(context, listen: false);

// Giriş butonunda
onPressed: () async {
  bool success = await authProvider.signIn(email, password);
  if (success) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    // Hata mesajı göster
  }
}
```

### Adım 2: signup_screen.dart'ı Güncelle
Benzer şekilde kayıt işlemini ekle:

```dart
// Provider'dan AuthProvider'ı al
final authProvider = Provider.of<AuthProvider>(context, listen: false);

// Kayıt butonunda
onPressed: () async {
  bool success = await authProvider.signUp(email, password);
  if (success) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    // Hata mesajı göster
  }
}
```

## 8. Auth Gate Oluşturma

### Adım 1: auth_gate.dart'ı Güncelle
Kullanıcının giriş durumuna göre yönlendirme yap:

```dart
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return SplashScreen();
        }
        
        if (authProvider.isAuthenticated) {
          return HomeScreen();
        } else {
          return SignInScreen();
        }
      },
    );
  }
}
```

## 9. Test Etme

### Adım 1: Uygulamayı Çalıştır
```bash
flutter run
```

### Adım 2: Firebase Console'da Kullanıcıları Kontrol Et
- Firebase Console > Authentication > Users
- Yeni kayıt olan kullanıcıları görebilirsin

## 10. Hata Ayıklama

### Yaygın Hatalar:
1. **google-services.json dosyası bulunamadı**: Dosyanın android/app/ klasöründe olduğundan emin ol
2. **Firebase başlatılamadı**: main() fonksiyonunda Firebase.initializeApp() çağrıldığından emin ol
3. **Authentication hatası**: Firebase Console'da Authentication servisinin etkin olduğundan emin ol

### Debug İpuçları:
- Firebase Console'da Authentication > Sign-in method bölümünden email/password'ü etkinleştir
- Test cihazının SHA-1 parmak izini Firebase'e ekle (gerekirse)

## 11. Sonraki Adımlar

Firebase Authentication çalıştıktan sonra:
- Kullanıcı profil bilgilerini Firestore'da saklayabilirsin
- Google Sign-In ekleyebilirsin
- Şifre sıfırlama özelliği ekleyebilirsin
- Email doğrulama ekleyebilirsin

Bu rehberi takip ederek Besinova uygulamasına Firebase Authentication başarıyla entegre edebilirsin.
