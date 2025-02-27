#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting WordPress local development environment...${NC}"

cp .env.local .env
echo -e "${GREEN}.env file created${NC}"

# Stop existing containers
echo -e "${YELLOW}Stopping existing containers...${NC}"
docker-compose -f docker-compose.local.yml down

# Start containers
echo -e "${YELLOW}Starting containers...${NC}"
docker-compose -f docker-compose.local.yml up -d

echo -e "${GREEN}WordPress local development environment started!${NC}"
echo -e "${GREEN}WordPress: http://localhost:8000 or http://$(grep WP_DOMAIN .env | cut -d '=' -f2)${NC}"
echo -e "${GREEN}PHPMyAdmin: http://localhost:8080 or http://$(grep PMA_DOMAIN .env | cut -d '=' -f2)${NC}"