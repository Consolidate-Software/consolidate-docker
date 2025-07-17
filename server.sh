#!/bin/bash

set -e

# --- Helper Functions for Colorized Output ---
C_BLUE="\033[1;34m"
C_GREEN="\033[1;32m"
C_RED="\033[1;31m"
C_YELLOW="\033[1;33m"
C_NC="\033[0m" # No Color

usage() {
    echo -e "${C_BLUE}Usage:${C_NC} $0 {configure|start|stop|update}"
    echo "  configure   Change the configuration"
    echo "  start      Start the application using Docker Compose"
    echo "  stop       Stop the application using Docker Compose"
    echo "  update     Update Consolidate to the latest version"
    exit 1
}

check_prerequisites() {
    echo -e "${C_BLUE}Checking for prerequisites...${C_NC}"
    if ! command -v docker &> /dev/null; then
        echo -e "${C_RED}Error: Docker is not installed. Please install Docker and try again.${C_NC}"
        echo "See: https://docs.docker.com/engine/install/"
        exit 1
    fi
    if ! docker compose version &> /dev/null; then
        echo -e "${C_RED}Error: Docker Compose is not available. Please ensure your Docker installation is up to date.${C_NC}"
        exit 1
    fi
    echo "Checking Docker permissions..."
    if ! docker info >/dev/null 2>&1; then
        echo -e "${C_RED}Error: The current user cannot access the Docker daemon.${C_NC}"
        echo "Please ensure you are in the 'docker' group or run this script with 'sudo'."
        echo -e "To add your user to the docker group, run: ${C_YELLOW}sudo usermod -aG docker $USER${C_NC}"
        echo "You must log out and log back in for this change to take effect."
        exit 1
    fi
    echo -e "${C_GREEN}Prerequisites met.${C_NC}\n"
}

configure_app() {
    check_prerequisites
    echo -e "${C_BLUE}--- Application Configuration ---${C_NC}"
    echo "I will now ask you a few questions to configure your application."

    # Try to preserve existing DATABASE_CERT_PASSWORD if present and not empty
    EXISTING_CERT_PASSWORD=""
    if [ -f .env ]; then
        EXISTING_CERT_PASSWORD=$(grep '^DATABASE_CERT_PASSWORD=' .env | cut -d'=' -f2- | tr -d '"')
        read -p "An existing .env file was found. Do you want to overwrite it? (y/N) " OVERWRITE
        if [[ "$OVERWRITE" != "y" && "$OVERWRITE" != "Y" ]]; then
            echo "Using existing .env file to start the application."
            start_app
            echo -e "\n${C_GREEN}✅ Application started successfully with existing configuration.${C_NC}"
            exit 0
        fi

        cp .env .env.bak
        echo -e "${C_YELLOW}Backup of existing .env created as .env.bak${C_NC}"
    fi

    echo -e "\n${C_YELLOW}1. Administrator Details${C_NC}"
    read -p "Enter the administrator's email address: " ADMIN_EMAIL
    while [ -z "$ADMIN_EMAIL" ]; do
        echo -e "${C_RED}Admin email cannot be empty.${C_NC}"
        read -p "Enter the administrator's email address: " ADMIN_EMAIL
    done

    while true; do
        read -s -p "Enter the administrator password: " ADMIN_PASSWORD
        echo
        read -s -p "Confirm password: " ADMIN_PASSWORD_CONFIRM
        echo
        if [ "$ADMIN_PASSWORD" = "$ADMIN_PASSWORD_CONFIRM" ] && [ -n "$ADMIN_PASSWORD" ]; then
            break
        else
            echo -e "${C_RED}Passwords do not match or are empty. Please try again.${C_NC}"
        fi
    done

    echo -e "\n${C_YELLOW}2. Domain and Network${C_NC}"
    read -p "Enter the public domain name (e.g., app.company.com): " DOMAIN_NAME
    while [ -z "$DOMAIN_NAME" ]; do
        echo -e "${C_RED}Domain name cannot be empty.${C_NC}"
        read -p "Enter the public domain name (e.g., app.company.com): " DOMAIN_NAME
    done

    read -p "Use default ports (HTTP: 80, HTTPS: 443)? (Y/n) " USE_DEFAULTS
    if [[ "$USE_DEFAULTS" == "n" || "$USE_DEFAULTS" == "N" ]]; then
        read -p "Enter HTTP port: " HTTP_PORT
        read -p "Enter HTTPS port: " HTTPS_PORT
    else
        HTTP_PORT="80"
        HTTPS_PORT="443"
    fi

    echo -e "\n${C_YELLOW}3. License Key${C_NC}"
    read -p "Enter your License key: " LICENSE_KEY

    # Only generate a new password if not present or empty
    if [ -n "$EXISTING_CERT_PASSWORD" ]; then
        DATABASE_CERT_PASSWORD="$EXISTING_CERT_PASSWORD"
        echo -e "${C_GREEN}Using existing database certificate password.${C_NC}"
    else
        echo "Generating a secure password for the database certificate..."
        DATABASE_CERT_PASSWORD=$(openssl rand -base64 32)
        echo -e "${C_GREEN}Database certificate password generated.${C_NC}"
    fi

    echo -e "\n${C_BLUE}Generating .env file...${C_NC}"
    cat > .env << EOF
# Auto-generated on $(date)
VERSION="latest"
ENVIRONMENT="Production"

LICENSE_KEY="$LICENSE_KEY"

DATABASE_NAME="Consolidate"
DATABASE_CERT_PASSWORD="$DATABASE_CERT_PASSWORD"
DATABASE_LICENSE=""

services__collabora__https__0="https://collabora.hosting.consolidate.eu"

# System Email Configuration
SystemEmail__Email=""
SystemEmail__Host=""
SystemEmail__Port=""
SystemEmail__Username=""
SystemEmail__Password=""

HTTP_PORT="$HTTP_PORT"
HTTPS_PORT="$HTTPS_PORT"
DATABASE_PORT="8080"

ADMIN_EMAIL="$ADMIN_EMAIL"
ADMIN_PASSWORD="$ADMIN_PASSWORD"

DOMAIN_NAME="$DOMAIN_NAME"

# Forwarded Headers (if running behind a reverse proxy)
# ASPNETCORE_FORWARDEDHEADERS_ENABLED="true"

# Backup Settings
Backup__Enabled="true"
# Backup__Interval="0 2 * * *" # Default every day at 2:00
# Backup__MinimumRetentionDays="14" # Default 14 days, set to 0 to retain indefinitely

# Uncomment if you want to upload your backup via FTP
# Backup__FtpUpload__Enabled="true"
# Backup__FtpUpload__Host=""
# Backup__FtpUpload__Port="21"
# Backup__FtpUpload__User=""
# Backup__FtpUpload__Password=""
# Backup__FtpUpload__Folder=""
EOF
    echo -e "${C_GREEN}Configuration file '.env' created successfully.${C_NC}"
    echo -e "If you need to change any settings, please check and edit this file before starting the application."
    echo -e "You can start the application with: ${C_YELLOW}$0 start${C_NC}"
}

start_app() {
    check_prerequisites
    if [ ! -f .env ]; then
        echo -e "${C_YELLOW}.env file not found. Running configuration first...${C_NC}"
        configure_app
        return;
    fi
    echo -e "\n${C_BLUE}Starting the application with Docker Compose...${C_NC}"
    docker compose up -d
    # Extract DOMAIN_NAME and ADMIN_EMAIL for display
    DOMAIN_NAME=$(grep '^DOMAIN_NAME=' .env | cut -d'=' -f2- | tr -d '"')
    ADMIN_EMAIL=$(grep '^ADMIN_EMAIL=' .env | cut -d'=' -f2- | tr -d '"')
    echo -e "\n${C_GREEN}✅ Application started successfully!${C_NC}"
    echo -e "You can access it at: ${C_YELLOW}https://$DOMAIN_NAME${C_NC}"
    echo -e "Admin user: ${C_YELLOW}$ADMIN_EMAIL${C_NC}"
    echo
    echo "To view logs, run: docker compose logs -f"
    echo "To stop the application, run: $0 stop"
}

stop_app() {
    check_prerequisites
    echo -e "\n${C_BLUE}Stopping the application with Docker Compose...${C_NC}"
    docker compose down
    echo -e "\n${C_GREEN}🛑 Application stopped.${C_NC}"
}

update_app() {
    check_prerequisites
    if [ ! -f .env ]; then
        echo -e "${C_RED}.env file not found. Please configure the application first.${C_NC}"
        exit 1
    fi

    echo -e "${C_BLUE}Checking for new commits on remote...${C_NC}"
    git fetch
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse @{u})
    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        echo -e "${C_BLUE}New commits found. Pulling latest version of the repository from remote...${C_NC}"
        git pull --rebase
        if [ $? -ne 0 ]; then
            echo -e "${C_RED}Failed to pull latest version from remote. Please resolve any git issues and try again.${C_NC}"
            exit 1
        fi
        echo -e "${C_GREEN}Repository updated to latest version.${C_NC}"
        echo -e "Re-running update script from the latest version..."
        exec "$0" update
        exit 0
    else
        echo -e "${C_GREEN}No new commits on remote. Proceeding with update...${C_NC}"
    fi

    # Always set VERSION to latest
    sed -i 's/^VERSION=.*/VERSION="latest"/' .env
    echo -e "${C_GREEN}Version set to latest in .env.${C_NC}"
    echo -e "Pulling latest image and restarting the application..."
    docker compose pull
    docker compose down
    docker compose up -d
    echo -e "${C_GREEN}✅ Application restarted with version latest.${C_NC}"
}

# --- Main ---
case "$1" in
    -h|--help)
        usage
        ;;
    configure)
        configure_app
        ;;
    start|"")
        start_app
        ;;
    stop)
        stop_app
        ;;
    update)
        update_app
        ;;
    *)
        usage
        ;;
esac
