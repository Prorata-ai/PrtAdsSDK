plugins {
    id("com.android.library") version "8.7.3"
    id("org.jetbrains.kotlin.android") version "1.9.10"
    id("maven-publish")
    id("signing")
}

android {
    namespace = "com.gist.ads.sdk"
    compileSdk = 34

    defaultConfig {
        minSdk = 24
        targetSdk = 34

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    buildFeatures {
        compose = true
    }
    
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.3"
    }
    
    // Enable publishing of sources and javadoc
    publishing {
        singleVariant("release") {
            withSourcesJar()
            withJavadocJar()
        }
    }
}

dependencies {
    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    
    // Compose - Updated to fix NoSuchMethodError with CircularProgressIndicator
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.runtime:runtime")
    
    // Networking
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    
    // JSON serialization
    implementation("com.google.code.gson:gson:2.10.1")
    
    // WebView for Compose
    implementation("androidx.webkit:webkit:1.9.0")
    
    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    
    // Lifecycle
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    
    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("io.mockk:mockk:1.13.8")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    testImplementation("com.squareup.okhttp3:mockwebserver:4.12.0")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-tooling")
}

publishing {
    publications {
        register<MavenPublication>("release") {
            groupId = "com.gist.ads"
            artifactId = "sdk"
            version = "1.0.4"

            afterEvaluate {
                from(components["release"])
            }
            
            pom {
                name.set("Gist Ads SDK")
                description.set("Native Android SDK for integrating Gist AI Search Ads into Android applications with Jetpack Compose")
                url.set("https://github.com/Prorata-ai/PrtAdsSDK")
                
                licenses {
                    license {
                        name.set("Proprietary License")
                        url.set("https://github.com/Prorata-ai/PrtAdsSDK/blob/main/android-sdk/LICENSE")
                    }
                }
                
                developers {
                    developer {
                        id.set("gist")
                        name.set("Gist")
                        email.set("support@gist.com")
                        organization.set("Gist")
                        organizationUrl.set("https://gist.com")
                    }
                }
                
                scm {
                    connection.set("scm:git:git://github.com/Prorata-ai/PrtAdsSDK.git")
                    developerConnection.set("scm:git:ssh://github.com/Prorata-ai/PrtAdsSDK.git")
                    url.set("https://github.com/Prorata-ai/PrtAdsSDK")
                }
            }
        }
    }
    
    repositories {
        // Maven Central (OSSRH)
        maven {
            name = "MavenCentral"
            val releasesRepoUrl = uri("https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/")
            val snapshotsRepoUrl = uri("https://s01.oss.sonatype.org/content/repositories/snapshots/")
            url = if (version.toString().endsWith("SNAPSHOT")) snapshotsRepoUrl else releasesRepoUrl
            
            credentials {
                username = project.findProperty("ossrhUsername") as String? ?: System.getenv("OSSRH_USERNAME")
                password = project.findProperty("ossrhPassword") as String? ?: System.getenv("OSSRH_PASSWORD")
            }
        }
        
        // Local Maven repository for testing
        maven {
            name = "LocalMaven"
            url = uri("${buildDir}/repo")
        }
    }
}

// Signing configuration for Maven Central
signing {
    // Use GPG agent or in-memory keys
    val signingKey = project.findProperty("signing.key") as String? ?: System.getenv("SIGNING_KEY")
    val signingPassword = project.findProperty("signing.password") as String? ?: System.getenv("SIGNING_PASSWORD")
    
    if (signingKey != null && signingPassword != null) {
        useInMemoryPgpKeys(signingKey, signingPassword)
    }
    
    sign(publishing.publications["release"])
}

// Skip signing for local builds
tasks.withType<Sign>().configureEach {
    onlyIf {
        project.hasProperty("signing.key") || System.getenv("SIGNING_KEY") != null
    }
}
