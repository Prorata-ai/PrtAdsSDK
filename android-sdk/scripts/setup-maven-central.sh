#!/bin/bash

# Maven Central Setup Helper Script
# This script helps you set up Maven Central publishing

set -e

echo "======================================"
echo "Maven Central Publishing Setup"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check GPG installation
echo "1. Checking GPG installation..."
if command -v gpg &> /dev/null; then
    echo -e "${GREEN}✓ GPG is installed$(gpg --version | head -1)${NC}"
else
    echo -e "${RED}✗ GPG is not installed${NC}"
    echo ""
    echo "Please install GPG:"
    echo "  macOS: brew install gnupg"
    echo "  Linux: sudo apt-get install gnupg"
    echo ""
    exit 1
fi

echo ""

# Check if GPG keys exist
echo "2. Checking for existing GPG keys..."
if gpg --list-secret-keys --keyid-format=long | grep -q "sec"; then
    echo -e "${GREEN}✓ GPG keys found:${NC}"
    gpg --list-secret-keys --keyid-format=long | grep -E "sec|uid"
    echo ""
    echo "Do you want to use an existing key? (y/n)"
    read -r use_existing
    
    if [[ "$use_existing" == "n" || "$use_existing" == "N" ]]; then
        create_new_key=true
    else
        create_new_key=false
        echo "Please enter your GPG Key ID (the part after rsa4096/):"
        read -r key_id
    fi
else
    echo -e "${YELLOW}⚠ No GPG keys found${NC}"
    create_new_key=true
fi

echo ""

# Create new GPG key if needed
if [ "$create_new_key" = true ]; then
    echo "3. Creating new GPG key..."
    echo "You will be prompted for:"
    echo "  - Key type: Press Enter (RSA and RSA)"
    echo "  - Key size: Enter 4096"
    echo "  - Expiration: Press Enter (no expiration) or enter 2y"
    echo "  - Your name and email"
    echo "  - A passphrase (SAVE THIS!)"
    echo ""
    read -p "Press Enter to continue..."
    
    gpg --full-generate-key
    
    echo ""
    echo "Getting your key ID..."
    key_id=$(gpg --list-secret-keys --keyid-format=long | grep "sec" | head -1 | sed 's/.*\/\([^ ]*\) .*/\1/')
    echo -e "${GREEN}✓ Key created with ID: $key_id${NC}"
fi

echo ""

# Upload public key to keyservers
echo "4. Uploading public key to keyservers..."
echo "This is required by Maven Central"
echo ""

gpg --keyserver keyserver.ubuntu.com --send-keys "$key_id" || echo "Warning: keyserver.ubuntu.com failed"
gpg --keyserver keys.openpgp.org --send-keys "$key_id" || echo "Warning: keys.openpgp.org failed"
gpg --keyserver pgp.mit.edu --send-keys "$key_id" || echo "Warning: pgp.mit.edu failed (this is common)"

echo -e "${GREEN}✓ Public key uploaded${NC}"
echo ""

# Export private key for CI/CD
echo "5. Exporting private key for CI/CD..."
private_key_file="/tmp/gpg-private-key-$(date +%s).txt"
gpg --export-secret-keys "$key_id" | base64 > "$private_key_file"
echo -e "${GREEN}✓ Private key exported to: $private_key_file${NC}"
echo -e "${YELLOW}⚠ Keep this file secure! It contains your private key.${NC}"
echo ""

# Check gradle.properties
echo "6. Checking Gradle properties..."
gradle_props="$HOME/.gradle/gradle.properties"

if [ -f "$gradle_props" ]; then
    echo -e "${GREEN}✓ Found $gradle_props${NC}"
    
    if grep -q "ossrhUsername" "$gradle_props"; then
        echo -e "${GREEN}✓ OSSRH credentials appear to be configured${NC}"
    else
        echo -e "${YELLOW}⚠ OSSRH credentials not found${NC}"
        add_credentials=true
    fi
else
    echo -e "${YELLOW}⚠ $gradle_props not found${NC}"
    add_credentials=true
fi

echo ""

# Prompt to add credentials
if [ "$add_credentials" = true ]; then
    echo "Would you like to add Maven Central credentials now? (y/n)"
    read -r add_now
    
    if [[ "$add_now" == "y" || "$add_now" == "Y" ]]; then
        echo ""
        echo "Enter your Sonatype OSSRH username:"
        read -r ossrh_username
        
        echo "Enter your Sonatype OSSRH password:"
        read -rs ossrh_password
        echo ""
        
        echo "Enter your GPG passphrase:"
        read -rs gpg_passphrase
        echo ""
        
        # Create gradle.properties
        mkdir -p "$HOME/.gradle"
        
        cat >> "$gradle_props" << EOF

# Maven Central Publishing (added by setup script)
ossrhUsername=$ossrh_username
ossrhPassword=$ossrh_password
signing.keyId=$key_id
signing.password=$gpg_passphrase
signing.secretKeyRingFile=$HOME/.gnupg/secring.gpg

EOF
        
        chmod 600 "$gradle_props"
        echo -e "${GREEN}✓ Credentials added to $gradle_props${NC}"
    fi
fi

echo ""
echo "======================================"
echo "Setup Summary"
echo "======================================"
echo ""
echo "GPG Key ID: $key_id"
echo "Private key export: $private_key_file"
echo "Gradle properties: $gradle_props"
echo ""
echo "Next Steps:"
echo ""
echo "1. Create Sonatype OSSRH account:"
echo "   → https://issues.sonatype.org/"
echo ""
echo "2. Create JIRA ticket to claim 'com.gist.ads':"
echo "   → https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134"
echo ""
echo "3. Wait for approval (1-2 business days)"
echo ""
echo "4. Test local publishing:"
echo "   cd android-sdk && ./gradlew publishToMavenLocal"
echo ""
echo "5. Publish to Maven Central:"
echo "   cd android-sdk && ./gradlew publishReleasePublicationToMavenCentralRepository"
echo ""
echo "For detailed instructions, see: MAVEN_CENTRAL_SETUP.md"
echo ""
echo -e "${GREEN}Setup complete!${NC}"

