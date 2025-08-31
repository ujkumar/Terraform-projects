# install_apache.sh
#!/bin/bash

# Update package index
sudo apt-get update -y

# Install Apache2
sudo apt-get install apache2 -y

# Enable and start Apache service
sudo systemctl enable apache2
sudo systemctl start apache2

# Print Apache status
sudo systemctl status apache2