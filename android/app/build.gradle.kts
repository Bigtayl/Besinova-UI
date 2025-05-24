plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Firebase plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.besinova"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ Firebase plugin'leri ile uyumlu versiyon

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
    applicationId = "com.example.besinova"
    minSdk = 23 // 🔥 Burayı elle sabitliyoruz
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}


    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 🔥 Firebase BoM (Bill of Materials) — sürümleri senkronize tutar
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))

    // ⚡ Firebase servisleri buradan Flutter tarafından yönetilir
    // Örnek: firebase-auth, firebase-core vs. Flutter pubspec.yaml'de olmalı

    // İstersen manuel eklemek için örnek:
    // implementation("com.google.firebase:firebase-auth-ktx")
}
