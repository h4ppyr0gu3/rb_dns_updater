#!/usr/bin/env bash

# URL of the file to download
file_url="https://raw.githubusercontent.com/h4ppyr0gu3/rb_dns_updater/master/updater.rb"

# Download the file
curl -o dns_updater -L "$file_url"

# Change file permissions to make it executable
chmod +x dns_updater

# Move the file to /usr/local/bin/dns_update
sudo mv dns_updater /usr/local/bin/dns_updater

echo "The file has been downloaded, made executable, and moved to /usr/local/bin/dns_updater"
