#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Set variables
DATE=$(date +%Y-%m-%d-%H%M)
BACKUP_DIR=${BACKUP_DIR:-/backups}
MYSQL_HOST=${MYSQL_HOST:-mysql}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-password}
MYSQL_DATABASE=${MYSQL_DATABASE:-wordpress}

# Create backup directory
mkdir -p ${BACKUP_DIR}/${DATE}

# Database backup
echo "Starting database backup..."
mysqldump -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} > ${BACKUP_DIR}/${DATE}/database.sql

# Files backup
echo "Starting files backup..."
tar -czf ${BACKUP_DIR}/${DATE}/files.tar.gz -C /var/www/html .

# Clean old backups (keep 7 days)
find ${BACKUP_DIR} -type d -name "20*" -mtime +7 -exec rm -rf {} \;

echo "Backup completed!"
echo "Backup files located: ${BACKUP_DIR}/${DATE}/" 