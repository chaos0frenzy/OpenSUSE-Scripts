#!/bin/bash

# Updated script to deploy Open WebUI using Docker on openSUSE Linux

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
for cmd in git docker docker-compose curl; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is not installed. Please install it and try again."
        exit 1
    fi
done

# Navigate to home directory
cd ~

# Clone or update the Open WebUI repository
if [ ! -d "open-webui" ]; then
    echo "Cloning Open WebUI repository..."
    git clone https://github.com/open-webui/open-webui.git
    cd open-webui
else
    echo "Updating existing Open WebUI repository..."
    cd open-webui
    git pull
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file. Please enter your API keys:"
    read -p "Enter your OpenAI API key (press Enter to skip): " openai_key
    read -p "Enter your Anthropic API key (press Enter to skip): " anthropic_key
    
    [ ! -z "$openai_key" ] && echo "OPENAI_API_KEY=$openai_key" > .env
    [ ! -z "$anthropic_key" ] && echo "ANTHROPIC_API_KEY=$anthropic_key" >> .env
    echo ".env file created successfully."
else
    echo ".env file already exists. Skipping creation."
fi

# Build and start Docker containers
echo "Building and starting Docker containers..."
docker-compose up --build -d

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 10

# Check container status
echo "Checking container status..."
docker-compose ps

# Check if the application is accessible
echo "Checking if Open WebUI is accessible..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080; then
    echo "Open WebUI is now running and accessible at http://localhost:8080"
else
    echo "Error: Unable to access Open WebUI. Please check the logs using 'docker-compose logs'."
    echo "You may need to check your Docker network settings or firewall configuration."
fi

echo "Deployment script completed. If you encounter any issues, please check the troubleshooting guide."
