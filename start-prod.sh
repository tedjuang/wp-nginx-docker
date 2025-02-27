#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if running on Ubuntu
is_ubuntu() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            return 0
        fi
    fi
    return 1
}

# Function to install Docker on Ubuntu
install_docker_ubuntu() {
    echo -e "${YELLOW}Installing Docker on Ubuntu...${NC}"
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker installed successfully!${NC}"
    echo -e "${YELLOW}NOTE: You may need to log out and log back in for group changes to take effect.${NC}"
}

# Function to install Docker Compose on Ubuntu
install_docker_compose_ubuntu() {
    echo -e "${YELLOW}Installing Docker Compose on Ubuntu...${NC}"
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose installed successfully!${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed.${NC}"
    
    # Auto-install for Ubuntu
    if is_ubuntu; then
        echo -e "${YELLOW}Ubuntu detected. Attempting to install Docker automatically...${NC}"
        install_docker_ubuntu
        
        # Verify installation
        if ! command -v docker &> /dev/null; then
            echo -e "${RED}Docker installation failed. Please install manually: https://docs.docker.com/get-docker/${NC}"
            exit 1
        fi
    else
        echo -e "Please install Docker first: https://docs.docker.com/get-docker/"
        exit 1
    fi
fi

# Check Docker version
DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
echo -e "${GREEN}Docker version: ${DOCKER_VERSION} installed${NC}"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed.${NC}"
    
    # Auto-install for Ubuntu
    if is_ubuntu; then
        echo -e "${YELLOW}Ubuntu detected. Attempting to install Docker Compose automatically...${NC}"
        install_docker_compose_ubuntu
        
        # Verify installation
        if ! command -v docker-compose &> /dev/null; then
            echo -e "${RED}Docker Compose installation failed. Please install manually: https://docs.docker.com/compose/install/${NC}"
            exit 1
        fi
    else
        echo -e "Please install Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi
fi

# Check Docker Compose version
COMPOSE_VERSION=$(docker-compose --version | cut -d ' ' -f3 | cut -d ',' -f1)
echo -e "${GREEN}Docker Compose version: ${COMPOSE_VERSION} installed${NC}"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon is not running.${NC}"
    echo -e "Attempting to start Docker daemon..."
    
    if is_ubuntu; then
        sudo systemctl start docker
        sleep 2
        
        if ! docker info &> /dev/null; then
            echo -e "${RED}Failed to start Docker daemon. Please start it manually.${NC}"
            exit 1
        else
            echo -e "${GREEN}Docker daemon started successfully!${NC}"
        fi
    else
        echo -e "Please start Docker daemon first."
        exit 1
    fi
fi

echo -e "${YELLOW}Starting WordPress production environment...${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found.${NC}"
    echo -e "${YELLOW}Please create your .env file manually by copying and modifying .env.prod:${NC}"
    echo -e "cp .env.prod .env"
    echo -e "Then edit .env to match your production environment settings."
    exit 1
fi

docker-compose -f docker-compose.prod.yml up -d

echo -e "${GREEN}WordPress production environment started!${NC}"

# Source the .env file to get the domain variables
if [ -f .env ]; then
    source .env
    echo "WordPress: https://${WP_DOMAIN}"
    echo "PHPMyAdmin: https://${PMA_DOMAIN}"
else
    echo -e "${YELLOW}Note: Unable to display domain URLs (missing .env file)${NC}"
fi

