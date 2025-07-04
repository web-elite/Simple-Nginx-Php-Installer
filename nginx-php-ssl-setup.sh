#!/bin/bash

# Colors
GREEN="\e[32m"
RESET="\e[0m"

echo -e "${GREEN}Starting Web Stack Setup...${RESET}"

# Update and install packages
sudo apt update
sudo apt install -y nginx php-fpm php-cli php-curl php-mbstring php-xml php-mysql php-zip unzip curl wget certbot python3-certbot-nginx ufw

# Enable & start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Enable firewall
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Menu
while true; do
  echo ""
  echo "==== Web Server Manager ===="
  echo "1. Add New Website"
  echo "2. Exit"
  read -p "Choose an option: " choice

  if [[ $choice == "1" ]]; then
    read -p "Enter domain name (e.g. example.com): " domain
    read -p "Enter custom port (e.g. 2087): " port
    read -p "Enter root directory (e.g. /var/www/example): " root_dir

    sudo mkdir -p $root_dir
    sudo chown -R $USER:$USER $root_dir
    echo "<?php phpinfo(); ?>" | sudo tee "$root_dir/index.php" > /dev/null

    # Create Nginx config
    nginx_config="/etc/nginx/sites-available/$domain"

    sudo tee $nginx_config > /dev/null <<EOF
server {
    listen $port;
    server_name $domain;

    root $root_dir;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    # Enable site
    sudo ln -s $nginx_config /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx

    # SSL via Certbot
    sudo certbot --nginx -d $domain --non-interactive --agree-tos -m admin@$domain

    echo -e "${GREEN}Site added: https://$domain on port $port${RESET}"
  elif [[ $choice == "2" ]]; then
    echo "Goodbye!"
    break
  else
    echo "Invalid option."
  fi
done