#!/bin/bash

REPO_URL="https://github.com/web-elite/Simple-Nginx-Php-Installer"
TARGET_DIR="$HOME/nginx-php-installer"

echo "Installing Nginx + PHP Installer..."
echo "Cloning from $REPO_URL"

# نصب ابزارهای پایه
sudo apt update
sudo apt install -y git curl

# کلون ریپو
if [ -d "$TARGET_DIR" ]; then
    echo "Removing previous installation..."
    rm -rf "$TARGET_DIR"
fi

git clone "$REPO_URL" "$TARGET_DIR"

# اجرای اسکریپت نصب
cd "$TARGET_DIR" || exit 1

chmod +x nginx-php-ssl-setup.sh
sudo ./nginx-php-ssl-setup.sh
