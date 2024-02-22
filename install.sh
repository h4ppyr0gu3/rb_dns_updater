#!/usr/bin/env bash

# URL of the file to download
file_url="https://raw.githubusercontent.com/user/repository/branch/path/to/file"

# Download the file
curl -o dns_update -L "$file_url"

# Change file permissions to make it executable
chmod +x dns_update

# Move the file to /usr/local/bin/dns_update
sudo mv dns_update /usr/local/bin/dns_update

echo "The file has been downloaded, made executable, and moved to /usr/local/bin/dns_update"
