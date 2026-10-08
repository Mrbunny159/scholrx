plugins {
    id("com.android.application")
    // 🟢 Firebase Plugin (Correct KTS placement)
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.scholrx" 
    compileSdk = 36
    buildToolsVersion = "36.0.0"
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // 🟢 YEH LINE NAYI ADD KARNI HAI
        isCoreLibraryDesugaringEnabled = true 
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.scholrx"
        minSdk = flutter.minSdkVersion  // 🟢 Firebase minimum requirement
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    // 🟢 YEH NAYA BLOCK FILE KE EKDM END ME AAYEGA
    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")    
    }
}

flutter {
    source = "../.."
}
