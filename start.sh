#!/bin/bash
set -e

echo "🚀 Starting Laravel School Management System..."

# Generate key if not set (fallback)
if [ -z "$APP_KEY" ]; then
    echo "⚠️ APP_KEY not set, generating one..."
    php artisan key:generate --force
fi

# Run database migrations
echo "📦 Running database migrations..."
php artisan migrate --force

# Cache configuration (now that env vars are available)
echo "⚙️ Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Clear any stale caches
php artisan cache:clear || true

echo "✅ Startup complete! Starting web server..."

# Start the Apache server
exec vendor/bin/heroku-php-apache2 public/
