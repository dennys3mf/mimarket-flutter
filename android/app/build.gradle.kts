// android/app/build.gradle.kts (actualizado)
android {
    namespace = "com.example.mi_tienda_app"
    compileSdk = 35  // Cambia de 36 a 35 (más estable)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Actualiza a 17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"  // Actualiza a 17
    }

    defaultConfig {
        applicationId = "com.example.mi_tienda_app"
        minSdk = 23  // Cambia minSdkVersion por minSdk
        targetSdk = 35  // Cambia targetSdkVersion y usa 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Habilita multidex (mejora rendimiento)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // Optimizaciones para release
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // Agrega multidex si tu app es grande
    implementation("androidx.multidex:multidex:2.0.1")
}