# Quick Start: Publishing the Android SDK

Choose your publishing option:

## Option 1: JitPack (⚡ Fast - Ready Now)

**Advantages:**
- Zero setup required
- Publish in 5 minutes
- No account needed
- Free

**Steps:**
```bash
# 1. Commit your changes
git add .
git commit -m "Release 1.0.1 - Enhanced error handling & clean build"

# 2. Tag the release
git tag -a 1.0.1 -m "Release 1.0.1"

# 3. Push to GitHub
git push origin main
git push origin 1.0.1

# 4. Done! JitPack builds automatically
# View at: https://jitpack.io/#Prorata-ai/PrtAdsSDK
```

**Users install with:**
```kotlin
repositories {
    maven { url = uri("https://jitpack.io") }
}

dependencies {
    implementation("com.github.Prorata-ai:PrtAdsSDK:1.0.1")
}
```

---

## Option 2: Maven Central (🏆 Professional - Takes 2-3 days)

**Advantages:**
- Official repository
- Trusted by enterprises
- Standard installation
- Better discoverability

**Current Status:**
✅ SDK configuration ready
✅ POM metadata complete
✅ Signing configuration ready
❌ Sonatype account needed
❌ GPG key needed

**Quick Start:**
```bash
# 1. Run the setup script
cd android-sdk
./scripts/setup-maven-central.sh

# 2. Follow the checklist
open MAVEN_CENTRAL_CHECKLIST.md
```

**Timeline:**
- Day 0: Install GPG, create account, submit JIRA ticket
- Day 1-2: Wait for Sonatype approval
- Day 3: Publish to Maven Central

**Users install with:**
```kotlin
dependencies {
    implementation("com.gist.ads:sdk:1.0.1")
}
```

---

## 📊 Comparison

| Feature | JitPack | Maven Central |
|---------|---------|---------------|
| Setup Time | 5 min | 2-3 days |
| Account Required | No | Yes |
| Approval Process | No | Yes (1-2 days) |
| Cost | Free | Free |
| Trust Level | Good | Excellent |
| Enterprise Adoption | Moderate | High |
| Discovery | GitHub | Maven Search |
| Recommendation | **Start here** | **For production** |

---

## 🎯 Recommended Approach

**For immediate testing/beta:**
→ Use JitPack (publish today)

**For production release:**
→ Set up Maven Central in parallel
→ Switch once approved

**Both options:**
→ Can co-exist
→ Same version numbers work

---

## 📁 Created Files

- `android-sdk/MAVEN_CENTRAL_SETUP.md` - Detailed setup guide
- `android-sdk/MAVEN_CENTRAL_CHECKLIST.md` - Step-by-step checklist
- `android-sdk/scripts/setup-maven-central.sh` - Automated setup helper
- `QUICK_START_PUBLISHING.md` - This file

---

## 🚀 Next Step

Choose one:

```bash
# Option 1: Publish to JitPack now (5 minutes)
git tag -a 1.0.1 -m "Release 1.0.1 - Enhanced error handling" && git push origin 1.0.1

# Option 2: Start Maven Central setup (2-3 days)
cd android-sdk && ./scripts/setup-maven-central.sh
```
