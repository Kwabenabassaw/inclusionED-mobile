pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    
    // UPDATED: Bumped AGP version from 8.9.1 to 8.11.1 to satisfy Flutter
    id("com.android.application") version "8.13.1" apply false 
    
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.4.4") apply false
    // END: FlutterFire Configuration
    
    // UPDATED: Bumped Kotlin version from 1.9.25 to 2.4.0 to satisfy Flutter
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false 
}

include(":app")