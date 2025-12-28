#!/bin/bash

# ==========================================
# macOS Privacy Permission Fixer
# ==========================================
# This script manually injects "Allowed" permissions into the macOS TCC database.
# Use this when apps fail to prompt for Microphone/Camera access.

DB_PATH="$HOME/Library/Application Support/com.apple.TCC/TCC.db"

# 1. Backup the database
TIMESTAMP=$(date +%s)
BACKUP_PATH="$DB_PATH.bak_$TIMESTAMP"
cp "$DB_PATH" "$BACKUP_PATH"
echo "✅ Database backed up to: $BACKUP_PATH"

# 2. Define the injection function
add_permission() {
    APP_ID="$1"
    SERVICE="$2"
    
    # SQL query for macOS 14+ (Sonoma) schema with 17 columns
    # Values: client_type=0 (Bundle), auth_value=2 (Allowed), auth_reason=2, auth_version=1
    QUERY="INSERT OR REPLACE INTO access VALUES('$SERVICE','$APP_ID',0,2,2,1,NULL,NULL,NULL,'UNUSED',NULL,0,strftime('%s','now'),NULL,NULL,'UNUSED',strftime('%s','now'));"
    
    sqlite3 "$DB_PATH" "$QUERY" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "   [OK] Granted $SERVICE to $APP_ID"
    else
        echo "   [ERROR] Failed to grant $SERVICE to $APP_ID (Check SIP/Database Lock)"
    fi
}

# 3. List of Apps to Fix (Add Bundle IDs here as needed)
# To find a Bundle ID, run: osascript -e 'id of app "AppName"'
declare -a apps=(
    "net.whatsapp.WhatsApp"
    "com.hnc.Discord"
    "us.zoom.xos"
    "com.google.Chrome"
    "com.apple.Terminal"
    "com.microsoft.VSCode"
    "com.tinyspeck.slackmacgap" # Slack
)

# 4. List of Services to Grant
declare -a services=(
    "kTCCServiceMicrophone"
    "kTCCServiceCamera"
    "kTCCServiceScreenCapture" # Screen Sharing
)

echo "💉 Injecting Permissions..."

for app in "${apps[@]}"; do
    for service in "${services[@]}"; do
        add_permission "$app" "$service"
    done
done

echo "=========================================="
echo "🎉 Done! Please restart the applications."
echo "If an app still doesn't work, ensure it isn't quarantined or broken."
