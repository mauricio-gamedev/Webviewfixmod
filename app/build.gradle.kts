plugins {
    id("com.android.application")
}

android {
    namespace = "io.github.astromg01.a06webcore.bench"
    compileSdk = 36

    defaultConfig {
        applicationId = "io.github.astromg01.a06webcore.bench"
        minSdk = 26
        targetSdk = 36
        versionCode = 1
        versionName = "0.1.1"

        buildConfigField("String", "CHROMIUM_BASELINE", "\"158.0.8127.36\"")
    }

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    lint {
        abortOnError = true
        checkReleaseBuilds = true
    }
}

dependencies {
    implementation("androidx.webkit:webkit:1.18.0")
}
