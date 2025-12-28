#!/bin/bash

# ==========================================
# macOS Privacy Permission Fixer
# ==========================================
# This script dynamically scans /Applications and grants Microphone, Camera,
# and Screen Capture permissions to ALL apps by injecting into the TCC database.
# Use this when apps fail to prompt for Microphone/Camera access.

set -euo pipefail

DB_PATH="$HOME/Library/Application Support/com.apple.TCC/TCC.db"
APPS_DIR="/Applications"

# Services to grant
declare -a SERVICES=(
    "kTCCServiceMicrophone"
    "kTCCServiceCamera"
    "kTCCServiceScreenCapture"
    "kTCCServiceSpeechRecognition"   # Dictation / Speech Recognition
    "kTCCServiceAccessibility"       # Accessibility (some apps need this for input)
)

# ==========================================
# Helper: Extract Bundle ID from an .app
# ==========================================
get_bundle_id() {
    local app_path="$1"
    local plist="$app_path/Contents/Info.plist"
    if [[ -f "$plist" ]]; then
        /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$plist" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# ==========================================
# Inject permission into TCC database
# ==========================================
add_permission() {
    local APP_ID="$1"
    local SERVICE="$2"

    # SQL query for macOS 14+ (Sonoma) schema with 17 columns
    # Values: client_type=0 (Bundle), auth_value=2 (Allowed), auth_reason=2, auth_version=1
    local QUERY="INSERT OR REPLACE INTO access VALUES('$SERVICE','$APP_ID',0,2,2,1,NULL,NULL,NULL,'UNUSED',NULL,0,strftime('%s','now'),NULL,NULL,'UNUSED',strftime('%s','now'));"

    if sqlite3 "$DB_PATH" "$QUERY" 2>/dev/null; then
        echo "   [OK] $SERVICE -> $APP_ID"
    else
        echo "   [ERROR] $SERVICE -> $APP_ID (Check SIP/Database Lock)"
    fi
}

# ==========================================
# Main
# ==========================================
echo "=========================================="
echo "🔍 Scanning $APPS_DIR for applications..."
echo "=========================================="

# 1. Backup the database
TIMESTAMP=$(date +%s)
BACKUP_PATH="$DB_PATH.bak_$TIMESTAMP"
if cp "$DB_PATH" "$BACKUP_PATH" 2>/dev/null; then
    echo "✅ Database backed up to: $BACKUP_PATH"
else
    echo "⚠️  Could not backup database (may need Full Disk Access)"
fi

# 2. Collect all bundle IDs from /Applications
declare -a BUNDLE_IDS=()
declare -a APP_NAMES=()  # Parallel array for app names
app_count=0
skipped_count=0

for app in "$APPS_DIR"/*.app; do
    [[ -d "$app" ]] || continue
    bundle_id=$(get_bundle_id "$app")
    app_name=$(basename "$app" .app)
    if [[ -n "$bundle_id" ]]; then
        BUNDLE_IDS+=("$bundle_id")
        APP_NAMES+=("$app_name")
        ((app_count++))
    else
        echo "   [SKIP] $app_name - no bundle ID found"
        ((skipped_count++))
    fi
done

echo ""
echo "📦 Found $app_count apps with valid bundle IDs ($skipped_count skipped)"
echo ""

# 3. Grant permissions
echo "💉 Injecting Permissions..."
echo "------------------------------------------"

granted=0
failed=0

for i in "${!BUNDLE_IDS[@]}"; do
    bundle_id="${BUNDLE_IDS[$i]}"
    app_name="${APP_NAMES[$i]}"
    echo "🔧 $app_name ($bundle_id)"
    for service in "${SERVICES[@]}"; do
        if add_permission "$bundle_id" "$service"; then
            ((granted++))
        else
            ((failed++))
        fi
    done
done

echo ""
echo "=========================================="
echo "🎉 Done!"
echo "   Apps processed: $app_count"
echo "   Permissions granted: $granted"
echo "   Errors: $failed"
echo ""
echo "⚠️  Please restart applications for changes to take effect."
echo "   If an app still doesn't work, ensure it isn't quarantined"
echo "   and that Terminal has Full Disk Access in System Settings."
echo "=========================================="
