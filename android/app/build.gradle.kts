import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    val content = keystorePropertiesFile
        .readText(Charsets.UTF_8)
        .removePrefix("\uFEFF")
    keystoreProperties.load(content.byteInputStream())
}

fun Properties.requireProperty(name: String): String =
    getProperty(name) ?: error("Missing '$name' in key.properties")

android {
    namespace = "com.tubigtrack.tubig_track"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.requireProperty("keyAlias")
                keyPassword = keystoreProperties.requireProperty("keyPassword")
                storeFile = rootProject.file(keystoreProperties.requireProperty("storeFile"))
                storePassword = keystoreProperties.requireProperty("storePassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.tubigtrack.tubig_track"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
