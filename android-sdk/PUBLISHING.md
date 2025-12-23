# Publishing Guide for Gist Ads SDK

This guide explains how to publish the Gist Ads SDK to different repositories.

## Table of Contents

1. [JitPack Publishing](#jitpack-publishing)
2. [Maven Central Publishing](#maven-central-publishing)
3. [Local Maven Publishing](#local-maven-publishing)
4. [Version Management](#version-management)

---

## JitPack Publishing

JitPack is the **easiest** option - it builds directly from GitHub with no manual publishing!

### Prerequisites

- GitHub repository with the SDK code
- Git tags for versioning

### Publishing Steps

1. **Create a Git Tag**:

   ```bash
   cd /path/to/PrtAdsSDK
   git tag -a 1.0.0 -m "Release version 1.0.0"
   git push origin 1.0.0
   ```

2. **Create a GitHub Release** (optional but recommended):
   - Go to <https://github.com/Prorata-ai/PrtAdsSDK/releases/new>
   - Select the tag you just created
   - Add release notes
   - Publish release

3. **That's it!** JitPack will automatically build when someone first requests the version:
   - First build takes 1-2 minutes
   - Subsequent installs are instant (cached)
   - View build status at: <https://jitpack.io/#Prorata-ai/PrtAdsSDK>

### Usage

Users add to their `settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        maven { url = uri("https://jitpack.io") }
    }
}
```

And in `build.gradle.kts`:

```kotlin
dependencies {
    implementation("com.github.Prorata-ai:PrtAdsSDK:1.0.0")
}
```

### Advanced JitPack Features

**Use specific commit:**

```kotlin
implementation("com.github.Prorata-ai:PrtAdsSDK:abc1234")  // commit hash
```

**Use latest snapshot:**

```kotlin
implementation("com.github.Prorata-ai:PrtAdsSDK:main-SNAPSHOT")
```

**Use specific branch:**

```kotlin
implementation("com.github.Prorata-ai:PrtAdsSDK:develop-SNAPSHOT")
```

---

## Maven Central Publishing

Maven Central is the **professional** option for production SDKs.

### Prerequisites

#### 1. Sonatype OSSRH Account

1. Create an account at <https://issues.sonatype.org/>
2. Create a JIRA ticket to claim your group ID (`com.gist.ads`)
3. Verify domain ownership or GitHub repository ownership
4. Wait for approval (usually 1-2 business days)

#### 2. GPG Signing Key

Create a GPG key for signing artifacts:

```bash
# Generate key
gpg --gen-key
# Follow prompts: use your name and email

# List keys to get key ID
gpg --list-secret-keys --keyid-format=long

# Export public key to keyserver
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID

# Export private key for CI/CD
gpg --export-secret-keys YOUR_KEY_ID | base64 > private-key.asc
```

#### 3. Configure Credentials

Create or update `~/.gradle/gradle.properties`:

```properties
# Sonatype credentials
ossrhUsername=your-sonatype-username
ossrhPassword=your-sonatype-password

# GPG signing
signing.keyId=YOUR_KEY_ID
signing.password=your-gpg-password
signing.secretKeyRingFile=/path/to/.gnupg/secring.gpg
```

**Or use in-memory keys** (recommended for CI/CD):

```properties
signing.key=<BASE64_ENCODED_PRIVATE_KEY>
signing.password=your-gpg-password
```

### Publishing Steps

#### Manual Publishing

1. **Update version** in `sdk.gradle.kts`:

   ```kotlin
   version = "1.0.0"  // Update this
   ```

2. **Build and publish**:

   ```bash
   cd android-sdk
   
   # Build the SDK
   ./gradlew clean build
   
   # Publish to OSSRH staging
   ./gradlew publishReleasePublicationToMavenCentralRepository
   ```

3. **Close and release** on Sonatype:
   - Go to <https://s01.oss.sonatype.org/>
   - Login with your credentials
   - Click "Staging Repositories"
   - Find your repository (com.gist.ads-XXXX)
   - Click "Close" (runs validation)
   - If successful, click "Release"

4. **Wait for sync** to Maven Central:
   - Usually takes 10-30 minutes
   - Can take up to 2 hours
   - Check at: <https://repo1.maven.org/maven2/com/gist/ads/sdk/>

#### Automated Publishing (GitHub Actions)

Create `.github/workflows/publish.yml`:

```yaml
name: Publish to Maven Central

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Decode GPG key
        run: |
          echo "${{ secrets.SIGNING_KEY }}" | base64 -d > /tmp/key.gpg
      
      - name: Publish to Maven Central
        env:
          OSSRH_USERNAME: ${{ secrets.OSSRH_USERNAME }}
          OSSRH_PASSWORD: ${{ secrets.OSSRH_PASSWORD }}
          SIGNING_KEY: ${{ secrets.SIGNING_KEY }}
          SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
        run: |
          cd android-sdk
          ./gradlew publishReleasePublicationToMavenCentralRepository
```

**Add GitHub Secrets:**

- `OSSRH_USERNAME`
- `OSSRH_PASSWORD`
- `SIGNING_KEY` (base64 encoded private key)
- `SIGNING_PASSWORD`

### Usage

Once published, users simply add:

```kotlin
dependencies {
    implementation("com.gist.ads:sdk:1.0.0")
}
```

---

## Local Maven Publishing

For testing the publishing process locally:

```bash
cd android-sdk

# Publish to local Maven repository (~/.m2/repository)
./gradlew publishToMavenLocal

# Or publish to custom location
./gradlew publishReleasePublicationToLocalMavenRepository
```

Users can then test with:

```kotlin
// In settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        mavenLocal()  // Add this
        google()
        mavenCentral()
    }
}

// In build.gradle.kts
dependencies {
    implementation("com.gist.ads:sdk:1.0.0")
}
```

---

## Version Management

### Versioning Scheme

We use [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH** (e.g., 1.0.0)
  - **MAJOR**: Incompatible API changes
  - **MINOR**: New functionality (backwards compatible)
  - **PATCH**: Bug fixes (backwards compatible)

### Release Process

1. **Update version** in `sdk.gradle.kts`:

   ```kotlin
   version = "1.1.0"  // Update
   ```

2. **Update CHANGELOG.md**:

   ```markdown
   ## [1.1.0] - 2024-12-20
   ### Added
   - New ad callback feature
   - Support for TEXT ad type
   
   ### Fixed
   - Ad click handling issue
   ```

3. **Commit and tag**:

   ```bash
   git add sdk.gradle.kts CHANGELOG.md
   git commit -m "Release version 1.1.0"
   git tag -a 1.1.0 -m "Release version 1.1.0"
   git push origin main
   git push origin 1.1.0
   ```

4. **Publish** (choose one):
   - **JitPack**: Automatic on tag push
   - **Maven Central**: Run publish command or GitHub Action

### Snapshot Versions

For development/testing versions:

```kotlin
version = "1.1.0-SNAPSHOT"
```

- JitPack: Use `main-SNAPSHOT` or `branch-SNAPSHOT`
- Maven Central: Published to snapshots repository

---

## Troubleshooting

### JitPack Issues

**Build fails on JitPack:**

- Check build log at <https://jitpack.io/#Prorata-ai/PrtAdsSDK/1.0.0>
- Ensure `jitpack.yml` is correct
- Verify gradlew has execute permissions: `git update-index --chmod=+x gradlew`

**Wrong artifact published:**

- Clear JitPack cache: <https://jitpack.io/#Prorata-ai/PrtAdsSDK>
- Click "Look up" and rebuild

### Maven Central Issues

**Signing fails:**

```bash
# Test signing locally
./gradlew signReleasePublication
```

**Upload fails:**

- Check credentials in `gradle.properties`
- Verify OSSRH account is approved
- Check repository URL is correct

**Validation fails:**

- Ensure POM has required fields (name, description, url, licenses, developers, scm)
- Verify sources and javadoc JARs are included
- Check artifact is signed

### General Issues

**Gradle sync fails:**

```bash
# Clean and rebuild
./gradlew clean --refresh-dependencies
./gradlew build
```

**Can't find published artifact:**

- JitPack: Wait for first build, check <https://jitpack.io/>
- Maven Central: Wait up to 2 hours for sync

---

## Security Best Practices

1. **Never commit credentials** to git
2. **Use environment variables** or `gradle.properties` (gitignored)
3. **Rotate keys** if compromised
4. **Use separate keys** for staging and production
5. **Store GPG keys securely** (password manager, CI/CD secrets)

---

## Additional Resources

- **JitPack Documentation**: <https://jitpack.io/docs/>
- **Maven Central Guide**: <https://central.sonatype.org/publish/publish-guide/>
- **Gradle Publishing Plugin**: <https://docs.gradle.org/current/userguide/publishing_maven.html>
- **Semantic Versioning**: <https://semver.org/>

---

## Support

For publishing issues:

- **JitPack**: <support@jitpack.io>
- **Maven Central**: <https://issues.sonatype.org/>
- **SDK Issues**: <support@gist.com>
