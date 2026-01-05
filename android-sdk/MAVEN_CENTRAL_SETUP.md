# Maven Central Publishing Setup Guide

This guide will walk you through setting up Maven Central publishing for the Gist Ads SDK.

## ⏱️ Timeline

- **Total setup time**: 2-3 business days
- **Account approval**: 1-2 business days
- **GPG setup**: 15 minutes
- **First publish**: 30 minutes

---

## 📋 Prerequisites Checklist

### Step 1: Install GPG (5 minutes)

GPG is not currently installed on your system. Install it:

```bash
# On macOS with Homebrew
brew install gnupg

# Verify installation
gpg --version
```

### Step 2: Create Sonatype OSSRH Account (1-2 business days)

1. **Sign up at Sonatype:**
   - Go to: https://issues.sonatype.org/
   - Click "Sign up" in the top right
   - Create account with your work email

2. **Create a JIRA ticket to claim your group ID:**
   - Go to: https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134
   - Fill in:
     - **Summary**: "Request publishing rights for com.gist.ads"
     - **Group Id**: `com.gist.ads`
     - **Project URL**: `https://github.com/Prorata-ai/PrtAdsSDK`
     - **SCM URL**: `https://github.com/Prorata-ai/PrtAdsSDK.git`
     - **Description**: "I would like to publish the Gist Ads SDK for Android to Maven Central"

3. **Verify GitHub repository ownership:**
   - Sonatype will ask you to verify GitHub repo access
   - They may ask you to:
     - Create a temporary GitHub repo like: `https://github.com/Prorata-ai/OSSRH-xxxxx`
     - Or add a specific TXT record to your domain

4. **Wait for approval:**
   - Usually takes 1-2 business days
   - You'll receive an email when approved

---

## 🔐 Step 3: Generate GPG Signing Key (15 minutes)

Once GPG is installed, run these commands:

```bash
# 1. Generate a new GPG key
gpg --full-generate-key

# When prompted:
# - Key type: (1) RSA and RSA (default)
# - Key size: 4096
# - Expiration: 0 (key does not expire) or 2y (2 years)
# - Real name: Your name (e.g., "Gist Development Team")
# - Email: Your work email (same as Sonatype account)
# - Passphrase: Create a strong passphrase (SAVE THIS!)

# 2. List your keys to get the Key ID
gpg --list-secret-keys --keyid-format=long

# Output will look like:
# sec   rsa4096/ABCD1234EFGH5678 2024-01-05 [SC]
#       1234567890ABCDEF1234567890ABCDEF12345678
# uid                 [ultimate] Your Name <your.email@example.com>
# ssb   rsa4096/1234567890ABCDEF 2024-01-05 [E]

# The Key ID is: ABCD1234EFGH5678 (the part after rsa4096/)

# 3. Export your public key to keyservers (required by Maven Central)
gpg --keyserver keyserver.ubuntu.com --send-keys ABCD1234EFGH5678
gpg --keyserver keys.openpgp.org --send-keys ABCD1234EFGH5678
gpg --keyserver pgp.mit.edu --send-keys ABCD1234EFGH5678

# 4. Export your private key for CI/CD (base64 encoded)
gpg --export-secret-keys ABCD1234EFGH5678 | base64 > /tmp/gpg-private-key.txt

# This file contains your private key - keep it secure!
```

---

## 🔧 Step 4: Configure Gradle Properties

Create `~/.gradle/gradle.properties` with your credentials:

```bash
# Create the file
mkdir -p ~/.gradle
touch ~/.gradle/gradle.properties
chmod 600 ~/.gradle/gradle.properties  # Secure permissions

# Edit the file (use your preferred editor)
nano ~/.gradle/gradle.properties
```

Add the following content (replace with your actual values):

```properties
# Sonatype OSSRH Credentials
ossrhUsername=your-sonatype-username
ossrhPassword=your-sonatype-password

# GPG Signing Configuration
signing.keyId=ABCD1234EFGH5678
signing.password=your-gpg-passphrase
signing.secretKeyRingFile=/Users/jpaulsen/.gnupg/secring.gpg

# Alternative: Use in-memory keys (recommended for CI/CD)
# signing.key=<paste base64 encoded key from /tmp/gpg-private-key.txt>
# signing.password=your-gpg-passphrase
```

**Important Security Notes:**
- ⚠️ Never commit this file to git
- ⚠️ Keep your GPG passphrase safe
- ⚠️ Store credentials in a password manager

---

## 🚀 Step 5: Test Local Publishing

Before publishing to Maven Central, test locally:

```bash
cd /Users/jpaulsen/workspace/PrtAdsSDK/android-sdk

# Clean build
./gradlew clean

# Test signing
./gradlew signReleasePublication

# If successful, you'll see:
# BUILD SUCCESSFUL

# Publish to local Maven for testing
./gradlew publishToMavenLocal

# Check the output
ls -la ~/.m2/repository/com/gist/ads/sdk/1.0.1/
```

---

## 📦 Step 6: Publish to Maven Central

Once your Sonatype account is approved and local testing works:

```bash
cd /Users/jpaulsen/workspace/PrtAdsSDK/android-sdk

# 1. Update version in sdk.gradle.kts if needed
# version = "1.0.1"

# 2. Build and publish
./gradlew clean build test
./gradlew publishReleasePublicationToMavenCentralRepository

# This will upload to OSSRH staging repository
```

### Step 7: Release via Sonatype UI

1. Go to: https://s01.oss.sonatype.org/
2. Login with your OSSRH credentials
3. Click "Staging Repositories" in left menu
4. Find your repository (com.gist.ads-XXXX)
5. Select it and click "Close" button
   - This runs validation checks
   - Wait for it to complete (usually 1-2 minutes)
6. If validation passes, click "Release" button
   - This publishes to Maven Central
7. Wait for sync to Maven Central (10-30 minutes)
8. Verify at: https://repo1.maven.org/maven2/com/gist/ads/sdk/

---

## 🤖 Optional: Automate with GitHub Actions

Create `.github/workflows/publish-maven-central.yml`:

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
          gpg --batch --import /tmp/key.gpg
      
      - name: Publish to Maven Central
        env:
          OSSRH_USERNAME: ${{ secrets.OSSRH_USERNAME }}
          OSSRH_PASSWORD: ${{ secrets.OSSRH_PASSWORD }}
          SIGNING_KEY_ID: ${{ secrets.SIGNING_KEY_ID }}
          SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
        run: |
          cd android-sdk
          ./gradlew publishReleasePublicationToMavenCentralRepository
```

**Add these GitHub Secrets:**
1. Go to: https://github.com/Prorata-ai/PrtAdsSDK/settings/secrets/actions
2. Add:
   - `OSSRH_USERNAME`: Your Sonatype username
   - `OSSRH_PASSWORD`: Your Sonatype password
   - `SIGNING_KEY`: Base64 encoded private key (from /tmp/gpg-private-key.txt)
   - `SIGNING_KEY_ID`: Your GPG key ID (e.g., ABCD1234EFGH5678)
   - `SIGNING_PASSWORD`: Your GPG passphrase

---

## 📝 Quick Reference Commands

```bash
# Check GPG keys
gpg --list-secret-keys --keyid-format=long

# Test signing
cd android-sdk && ./gradlew signReleasePublication

# Publish locally
cd android-sdk && ./gradlew publishToMavenLocal

# Publish to Maven Central
cd android-sdk && ./gradlew publishReleasePublicationToMavenCentralRepository

# Check published artifacts
ls -la ~/.m2/repository/com/gist/ads/sdk/1.0.1/
```

---

## ❓ Troubleshooting

### "gpg: signing failed: No secret key"
```bash
# Re-import your key
gpg --import /path/to/private-key.asc
```

### "401 Unauthorized" when publishing
```bash
# Check your credentials in ~/.gradle/gradle.properties
# Verify your Sonatype account is approved
```

### "POM validation failed"
- Ensure all required POM fields are filled (already done in sdk.gradle.kts)
- Check that sources and javadoc JARs are being generated

### "Cannot find keyserver"
```bash
# Try different keyservers
gpg --keyserver hkp://keyserver.ubuntu.com:80 --send-keys YOUR_KEY_ID
```

---

## 🎉 Success!

Once published, users can add your SDK to their projects:

```kotlin
dependencies {
    implementation("com.gist.ads:sdk:1.0.1")
}
```

---

## 🔗 Useful Links

- Sonatype OSSRH: https://issues.sonatype.org/
- Maven Central Search: https://search.maven.org/
- Staging Repository: https://s01.oss.sonatype.org/
- Publishing Guide: https://central.sonatype.org/publish/publish-guide/
- GPG Documentation: https://gnupg.org/documentation/

---

## 📞 Support

- Sonatype Support: https://issues.sonatype.org/
- Maven Central Guide: https://central.sonatype.org/
- SDK Issues: https://github.com/Prorata-ai/PrtAdsSDK/issues

