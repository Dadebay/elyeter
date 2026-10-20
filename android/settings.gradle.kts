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
    id("com.android.application") version "9.0.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.4.4") apply false
    // END: FlutterFire Configuration
    // Select the compiler version without applying the standalone Kotlin plugin.
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")

// These releases retain legacy Kotlin fallback code that Flutter 3.47's
// static scanner flags even with built-in Kotlin enabled. Use migrated build
// scripts while keeping each package's original sources and project directory.
mapOf("firebase_core" to "4.15.0", "location" to "10.0.2").forEach { (name, version) ->
    val plugin = project(":$name")
    val packageVersion = plugin.projectDir.resolve("../pubspec.yaml")
        .readLines().first { it.startsWith("version:") }
        .substringAfter(":").trim()
    check(packageVersion == version) {
        "Review gradle/plugin-builds/$name.gradle for $name $packageVersion before upgrading."
    }
    plugin.buildFileName = file("gradle/plugin-builds/$name.gradle")
        .relativeTo(plugin.projectDir).path
}
