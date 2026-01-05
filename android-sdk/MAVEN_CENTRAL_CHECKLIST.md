# Maven Central Publishing Checklist

Use this checklist to track your Maven Central setup progress.

## 🎯 Quick Start (Do This Now)

### Immediate Actions (15 minutes)

- [ ] **Install GPG**
  ```bash
  brew install gnupg
  gpg --version
  ```

- [ ] **Run the setup script**
  ```bash
  cd /Users/jpaulsen/workspace/PrtAdsSDK/android-sdk
  ./scripts/setup-maven-central.sh
  ```

- [ ] **Create Sonatype account**
  - Go to: https://issues.sonatype.org/
  - Click "Sign up"
  - Use your work email
  - Verify email address

---

## 📋 Complete Setup Process

### Phase 1: Account Setup (Today - 1-2 business days)

- [ ] Create Sonatype OSSRH account
- [ ] Create JIRA ticket for `com.gist.ads` group ID
  - Template: https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134
  - Fill in:
    - Summary: "Request publishing rights for com.gist.ads"
    - Group Id: `com.gist.ads`
    - Project URL: `https://github.com/Prorata-ai/PrtAdsSDK`
    - SCM URL: `https://github.com/Prorata-ai/PrtAdsSDK.git`

- [ ] Verify GitHub repository ownership
  - Sonatype will comment on your ticket
  - Follow their verification instructions

- [ ] Wait for approval email
  - Usually 1-2 business days
  - Check JIRA ticket for updates

---

### Phase 2: GPG Configuration (15 minutes)

- [ ] Generate GPG key (or use existing)
  ```bash
  gpg --full-generate-key
  ```

- [ ] Get your GPG Key ID
  ```bash
  gpg --list-secret-keys --keyid-format=long
  ```

- [ ] Upload public key to keyservers
  ```bash
  gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
  gpg --keyserver keys.openpgp.org --send-keys YOUR_KEY_ID
  ```

- [ ] Export private key for CI/CD
  ```bash
  gpg --export-secret-keys YOUR_KEY_ID | base64 > /tmp/gpg-key.txt
  ```

- [ ] Save GPG passphrase securely
  - [ ] Store in password manager
  - [ ] Share with team if needed

---

### Phase 3: Credential Configuration (10 minutes)

- [ ] Create `~/.gradle/gradle.properties`
- [ ] Add Sonatype credentials
  ```properties
  ossrhUsername=your-username
  ossrhPassword=your-password
  ```

- [ ] Add GPG signing configuration
  ```properties
  signing.keyId=YOUR_KEY_ID
  signing.password=your-gpg-passphrase
  signing.secretKeyRingFile=/Users/jpaulsen/.gnupg/secring.gpg
  ```

- [ ] Secure the file
  ```bash
  chmod 600 ~/.gradle/gradle.properties
  ```

---

### Phase 4: Local Testing (20 minutes)

- [ ] Test signing
  ```bash
  cd android-sdk
  ./gradlew signReleasePublication
  ```

- [ ] Publish to local Maven
  ```bash
  ./gradlew publishToMavenLocal
  ```

- [ ] Verify local artifacts
  ```bash
  ls -la ~/.m2/repository/com/gist/ads/sdk/1.0.1/
  ```

- [ ] Test in a sample project
  - Create test project
  - Add `mavenLocal()` to repositories
  - Try implementing the SDK

---

### Phase 5: First Publish (30 minutes)

**Wait until Sonatype account is approved!**

- [ ] Update version in `sdk.gradle.kts` (if needed)
- [ ] Run full build and tests
  ```bash
  ./gradlew clean build test
  ```

- [ ] Publish to Maven Central staging
  ```bash
  ./gradlew publishReleasePublicationToMavenCentralRepository
  ```

- [ ] Login to Sonatype Nexus
  - URL: https://s01.oss.sonatype.org/
  - Use your OSSRH credentials

- [ ] Find your staging repository
  - Click "Staging Repositories"
  - Search for `com.gist.ads`

- [ ] Close the repository
  - Select your repository
  - Click "Close" button
  - Wait for validation (1-2 minutes)

- [ ] Release to Maven Central
  - Select your repository
  - Click "Release" button
  - Confirm release

- [ ] Wait for sync to Maven Central
  - Usually 10-30 minutes
  - Can take up to 2 hours

- [ ] Verify publication
  - Check: https://repo1.maven.org/maven2/com/gist/ads/sdk/1.0.1/
  - Search: https://search.maven.org/search?q=com.gist.ads

---

### Phase 6: Automation (Optional - 1 hour)

- [ ] Create GitHub Actions workflow
  - Copy from `MAVEN_CENTRAL_SETUP.md`
  - Save as `.github/workflows/publish-maven-central.yml`

- [ ] Add GitHub Secrets
  - `OSSRH_USERNAME`
  - `OSSRH_PASSWORD`
  - `SIGNING_KEY` (base64 encoded private key)
  - `SIGNING_KEY_ID`
  - `SIGNING_PASSWORD`

- [ ] Test automated workflow
  - Create a test release
  - Watch GitHub Actions run

---

## 🎉 Post-Publication

- [ ] Update README with installation instructions
- [ ] Announce on social media / blog
- [ ] Update documentation website
- [ ] Notify users of the new version
- [ ] Monitor for issues

---

## 📞 Contact Information

Save these for reference:

- **Sonatype OSSRH**: https://issues.sonatype.org/
- **Staging Repository**: https://s01.oss.sonatype.org/
- **Maven Central Search**: https://search.maven.org/
- **Your JIRA ticket**: (save link here once created)
- **Your GPG Key ID**: (save here once generated)

---

## ⏱️ Expected Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| Install GPG | 5 min | ⏳ |
| Create Sonatype account | 10 min | ⏳ |
| JIRA ticket & verification | 1-2 days | ⏳ |
| GPG key generation | 15 min | ⏳ |
| Configure credentials | 10 min | ⏳ |
| Local testing | 20 min | ⏳ |
| First publish | 30 min | ⏳ |
| Maven Central sync | 10-30 min | ⏳ |
| **Total** | **2-3 days** | ⏳ |

---

## 🚨 Important Notes

1. **Don't commit credentials** to git
2. **Save your GPG passphrase** - you can't recover it
3. **Test locally first** before publishing
4. **Be patient** - approval takes 1-2 business days
5. **Keep private key secure** - treat it like a password

---

## ✅ Success Criteria

You'll know you're successful when:

1. ✅ JIRA ticket is marked "Resolved"
2. ✅ Local publish works without errors
3. ✅ Staging repository closes without validation errors
4. ✅ Artifact appears on Maven Central: https://repo1.maven.org/maven2/com/gist/ads/sdk/
5. ✅ Users can add dependency without issues:
   ```kotlin
   implementation("com.gist.ads:sdk:1.0.1")
   ```

---

## 📚 Resources

- Full guide: `MAVEN_CENTRAL_SETUP.md`
- Setup script: `scripts/setup-maven-central.sh`
- Sonatype guide: https://central.sonatype.org/publish/publish-guide/

