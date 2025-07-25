#!/bin/bash

# Update package list
sudo apt-get update

# Install Apache2
sudo apt-get install -y apache2
echo "Hello Gabbarsingh A, World!" > /var/www/html/index.html
# Enable and start Apache2 service
sudo systemctl enable apache2
sudo systemctl start apache2
