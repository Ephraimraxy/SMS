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

# Configure Apache port if PORT env var is set
if [ ! -z "$PORT" ]; then
    echo "🔌  Configuring Apache to listen on port $PORT..."
    sed -i "s/80/$PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
fi

echo "✅ Startup complete! Starting web server..."

# Start the Apache server (standard PHP image command)
exec apache2-foreground
