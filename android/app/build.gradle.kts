plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Firebase plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.besinova"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Firebase plugin compatible version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
    applicationId = "com.example.besinova"
    minSdk = 23 // Set minimum SDK version manually
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
    // Core library desugaring for Java 8+ features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Firebase BoM (Bill of Materials) - keeps versions synchronized
    implementation(platform("com.google.firebase:firebase-bom:32.7.4"))

    // Firebase services managed by Flutter
    // Example: firebase-auth, firebase-core etc. should be in Flutter pubspec.yaml

    // Manual addition example if needed:
    // implementation("com.google.firebase:firebase-auth-ktx")
}
