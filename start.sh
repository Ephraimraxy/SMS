#!/bin/bash
set -e

echo "🚀 Starting Laravel School Management System..."

# Copy .env if not exists - but we'll override values from environment
if [ ! -f ".env" ]; then
    echo "⚠️ .env not found, copying from .env.example..."
    cp .env.example .env 2>/dev/null || touch .env
fi

# CRITICAL: Write Railway environment variables to .env file
# This ensures Laravel reads them correctly (env file takes precedence)
echo "📝 Syncing environment variables to .env..."

# App settings from Railway environment
[ -n "$APP_KEY" ] && sed -i "s|^APP_KEY=.*|APP_KEY=$APP_KEY|g" .env || true
[ -n "$APP_NAME" ] && sed -i "s|^APP_NAME=.*|APP_NAME=\"$APP_NAME\"|g" .env || true
[ -n "$APP_ENV" ] && sed -i "s|^APP_ENV=.*|APP_ENV=$APP_ENV|g" .env || true
[ -n "$APP_DEBUG" ] && sed -i "s|^APP_DEBUG=.*|APP_DEBUG=true|g" .env || true
[ -n "$APP_URL" ] && sed -i "s|^APP_URL=.*|APP_URL=$APP_URL|g" .env || true

# Database settings from Railway environment  
[ -n "$DB_CONNECTION" ] && sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=$DB_CONNECTION|g" .env || true
[ -n "$DB_HOST" ] && sed -i "s|^DB_HOST=.*|DB_HOST=$DB_HOST|g" .env || true
[ -n "$DB_PORT" ] && sed -i "s|^DB_PORT=.*|DB_PORT=$DB_PORT|g" .env || true
[ -n "$DB_DATABASE" ] && sed -i "s|^DB_DATABASE=.*|DB_DATABASE=$DB_DATABASE|g" .env || true
[ -n "$DB_USERNAME" ] && sed -i "s|^DB_USERNAME=.*|DB_USERNAME=$DB_USERNAME|g" .env || true
[ -n "$DB_PASSWORD" ] && sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=$DB_PASSWORD|g" .env || true

# Ensure APP_KEY line exists if not already in file
if ! grep -q "^APP_KEY=" .env && [ -n "$APP_KEY" ]; then
    echo "APP_KEY=$APP_KEY" >> .env
fi

echo "✅ Environment variables synced"

# Run database migrations
echo "📦 Running database migrations..."
php artisan migrate --force 2>/dev/null || echo "⚠️ Migrations skipped (DB may not be ready)"

# Clear and rebuild cache
echo "🧹 Clearing caches..."
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan view:clear 2>/dev/null || true

# Fix permissions
echo "🔒 Fixing permissions..."
chmod -R 755 storage bootstrap/cache 2>/dev/null || true

# Create storage symlink (ignore if exists)
php artisan storage:link 2>/dev/null || true

# Set log channel for Railway visibility
if ! grep -q "^LOG_CHANNEL=" .env; then
    echo "LOG_CHANNEL=stderr" >> .env
fi

# Get port from Railway (default 8080)
PORT="${PORT:-8080}"
echo "🔌 Starting PHP server on port $PORT..."

# Start Laravel server
exec php artisan serve --host=0.0.0.0 --port="$PORT"
