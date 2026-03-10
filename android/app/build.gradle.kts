plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.oneconnect"
    compileSdk = 36
    ndkVersion = "29.0.14033849"

    compileOptions {
        // ✅ Use Java 17 (Flutter official support)
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // ✅ Also use JVM target 17
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.oneconnect"
        minSdk = 23  // Required for Firebase Auth and geolocator_android plugin
        // ✅ match targetSdk with compileSdk
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        debug {
            // Enable hot reload optimizations for debug builds
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
