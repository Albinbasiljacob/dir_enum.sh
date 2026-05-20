#!/bin/bash

# =============================================
#   Website Directory Enumeration Tool
#               by ALBIN
# =============================================

clear
echo "══════════════════════════════════════════════"
echo "     DIRECTORY ENUMERATION SCANNER"
echo "               by ALBIN"
echo "══════════════════════════════════════════════"
echo ""

# Check if curl is installed
if ! command -v curl >/dev/null 2>&1; then
    echo "❌ curl is not installed. Please install it first."
    echo "   sudo apt install curl -y"
    exit 1
fi

# Usage
if [ -z "$1" ]; then
    echo "Usage: $0 <URL> [WORDLIST]"
    echo ""
    echo "Example:"
    echo "   $0 https://example.com"
    echo "   $0 https://example.com /usr/share/wordlists/dirb/common.txt"
    exit 1
fi

TARGET="$1"
WORDLIST="${2:-/usr/share/wordlists/dirb/common.txt}"

# Remove trailing slash if present
TARGET=${TARGET%/}

echo "Target    : $TARGET"
echo "Wordlist  : $WORDLIST"
echo "──────────────────────────────────────────────"
echo ""

# Check if wordlist exists
if [ ! -f "$WORDLIST" ]; then
    echo "❌ Wordlist not found: $WORDLIST"
    echo "Using a small built-in wordlist instead..."
    WORDLIST="/tmp/default_wordlist.txt"
    cat > "$WORDLIST" << EOF
admin
login
dashboard
wp-admin
administrator
config
backup
test
phpmyadmin
images
css
js
uploads
secret
panel
api
EOF
fi

echo "Starting directory enumeration..."
echo "Press Ctrl+C to stop."
echo ""

found=0

while IFS= read -r dir || [ -n "$dir" ]; do
    # Skip empty lines and comments
    [[ -z "$dir" || "$dir" =~ ^# ]] && continue

    # Remove leading slash if present
    dir=${dir#/}

    URL="$TARGET/$dir"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" -I --max-time 5 -H "User-Agent: Mozilla/5.0" "$URL")
    
    case $response in
        200)
            echo -e "\e[32m[200] Found → $URL\e[0m"
            ((found++))
            ;;
        301|302)
            echo -e "\e[33m[301] Redirect → $URL\e[0m"
            ((found++))
            ;;
        403)
            echo -e "\e[35m[403] Forbidden → $URL\e[0m"
            ;;
        500)
            echo -e "\e[31m[500] Server Error → $URL\e[0m"
            ;;
        *)
            # Optional: show only found ones (uncomment below if you want all)
            # echo -e "\e[90m[$response] $URL\e[0m"
            ;;
    esac

done < "$WORDLIST"

echo ""
echo "══════════════════════════════════════════════"
echo "Scan Completed! Directories Found : $found"
echo "               Script by ALBIN"
echo "══════════════════════════════════════════════"
echo ""

echo "💡 Tip: For better & faster scanning, use:"
echo "   gobuster dir -u $TARGET -w $WORDLIST"
