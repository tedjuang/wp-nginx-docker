# WordPress Docker Environment

Docker-based WordPress development and production environment.

## Project Architecture

```
WordPress Docker
├── nginx-proxy  <-- Reverse proxy, handling multiple domains and HTTPS
├── letsencrypt  <-- Automatic SSL certificates (production only)
├── wordpress_nginx  <-- WordPress Nginx server
├── wordpress  <-- WordPress core (PHP-FPM)
├── mysql  <-- MariaDB database
└── phpmyadmin  <-- Database management tool
```

### Technology Stack

- WordPress 6.4.2 (PHP 8.2)
- Nginx 1.25
- MariaDB 10.11.5
- Docker & Docker Compose

## Usage

### Environment Configuration

The project includes the following environment files:
- `.env.example` - Example configuration file (contains all possible configuration options and descriptions)
- `.env.local` - Local development environment template
- `.env.prod` - Production environment template

Before starting, please create and configure your environment file:
```bash
cp .env.example .env
# Then edit the .env file to set your configuration
```

### Local Development Environment

1. Copy and configure environment variables
```bash
cp .env.local .env
# Edit the .env file to set domains and database credentials
```

2. Add local domain resolution (edit /etc/hosts file)
```
127.0.0.1 local.example.com pma.local.example.com
```

3. Start local environment
```bash
./start-local.sh
# Or
docker-compose -f docker-compose.local.yml up -d
```

4. Access services
- WordPress: http://local.example.com or http://localhost:8000
- PHPMyAdmin: http://pma.local.example.com or http://localhost:8080

### Production Environment

1. Copy and configure environment variables
```bash
cp .env.prod .env
# Edit the .env file to set domains and database credentials
```

2. Start production environment
```bash
./start-prod.sh
# Or
docker-compose -f docker-compose.prod.yml up -d
```

3. Access services
- WordPress: https://your-wp-domain.com
- PHPMyAdmin: https://your-pma-domain.com

## Security Tips

### WordPress Security Keys

When configuring WordPress security keys (AUTH_KEY, SECURE_AUTH_KEY, etc.) in the `.env` file, please note:

1. **Use unique keys** - Each WordPress site should use a different set of keys
2. **Rotate periodically** - If you suspect your site has been compromised, changing these keys will invalidate all existing cookies, forcing all users (including potential hackers) to log out
3. **Keep confidential** - These keys should be kept confidential, not shared or committed to version control

Generate random security keys:
```bash
curl -s https://api.wordpress.org/secret-key/1.1/salt/
```