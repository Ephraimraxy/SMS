#!/bin/bash
set -e

echo "🚀 Starting Laravel School Management System..."

# Generate key if not set (fallback)
if [ ! -f ".env" ]; then
    echo "⚠️ .env not found, copying from .env.example..."
    cp .env.example .env || true
fi

if [ -z "$APP_KEY" ]; then
    echo "⚠️ APP_KEY not set, generating one..."
    php artisan key:generate --force || true
fi

# Run database migrations (don't fail if DB isn't ready)
echo "📦 Running database migrations..."
php artisan migrate --force || echo "⚠️ Migrations failed, skipping..."

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
    sed -i "s/Listen 80/Listen $PORT/g" /etc/apache2/ports.conf
    sed -i "s/<VirtualHost \*:80>/<VirtualHost *:$PORT>/g" /etc/apache2/sites-available/000-default.conf
else
    echo "⚠️  PORT variable not set, defaulting to 80"
fi

echo "✅ Startup complete! Starting web server..."

# Start the Apache server (standard PHP image command)
exec apache2-foreground
