#!/bin/bash

echo "=========================================="
echo "KEYCHAIN COMPROMISE CHECK"
echo "=========================================="
echo ""

# Check keychain file
echo "1. Checking Keychain file..."
KEYCHAIN_FILE="$HOME/Library/Keychains/login.keychain-db"
if [ -f "$KEYCHAIN_FILE" ]; then
    echo "   ✓ Keychain file exists"
    echo "   Location: $KEYCHAIN_FILE"
    echo "   Last modified: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$KEYCHAIN_FILE")"
    echo "   Size: $(du -h "$KEYCHAIN_FILE" | cut -f1)"
else
    echo "   ⚠ Keychain file not found"
fi

echo ""
echo "2. Checking for suspicious network connections..."
if lsof -i @88.218.0.78:101 2>/dev/null | grep -q .; then
    echo "   🔴 ACTIVE CONNECTION TO MALICIOUS SERVER DETECTED!"
    lsof -i @88.218.0.78:101
else
    echo "   ✓ No active connections to malicious server"
fi

echo ""
echo "3. Checking for exfiltrated files..."
FOUND_FILES=0

# Check for zip files
if find ~ -maxdepth 3 -name "*.zip" -mtime -7 2>/dev/null | grep -q .; then
    echo "   ⚠ Recent zip files found:"
    find ~ -maxdepth 3 -name "*.zip" -mtime -7 -ls 2>/dev/null
    FOUND_FILES=1
fi

# Check for malicious payload files
if [ -f ~/.nlq ]; then
    echo "   🔴 MALICIOUS PAYLOAD FILE FOUND: ~/.nlq"
    ls -la ~/.nlq
    FOUND_FILES=1
fi

if [ $FOUND_FILES -eq 0 ]; then
    echo "   ✓ No suspicious files found"
fi

echo ""
echo "4. Checking browser data files..."
if [ -f "$HOME/Library/Application Support/Google/Chrome/User Data/Default/Login Data" ]; then
    echo "   ⚠ Chrome Login Data exists"
    echo "   Last modified: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$HOME/Library/Application Support/Google/Chrome/User Data/Default/Login Data" 2>/dev/null || echo 'unknown')"
fi

echo ""
echo "5. Checking for cryptocurrency wallets..."
if [ -f ~/.config/Exodus/exodus.wallet ]; then
    echo "   🔴 EXODUS WALLET FOUND - CONSIDER COMPROMISED!"
    ls -la ~/.config/Exodus/exodus.wallet
fi

if find ~/.config -name "*solana*" 2>/dev/null | grep -q .; then
    echo "   ⚠ Solana wallet files found:"
    find ~/.config -name "*solana*" -ls 2>/dev/null
fi

echo ""
echo "=========================================="
echo "RECOMMENDATION:"
echo "=========================================="
echo "If malicious server was running, assume:"
echo "  - All Keychain passwords compromised"
echo "  - All browser passwords compromised"
echo "  - Cryptocurrency wallets at risk"
echo ""
echo "IMMEDIATE ACTIONS:"
echo "  1. Change Keychain password"
echo "  2. Change all saved passwords"
echo "  3. Secure cryptocurrency wallets"
echo "  4. Rotate SSH keys and API tokens"
echo ""
