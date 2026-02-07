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
php artisan migrate --force || echo "⚠️ Migrations failed, but starting server anyway..."

# Clear caches
echo "🧹 Clearing caches..."
php artisan optimize:clear || echo "⚠️ Failed to clear cache (check permissions?)"

# Fallback for APP_KEY if it's still empty (prevent boot loop)
if [ -z "$APP_KEY" ] && [ ! -f .env ]; then
   echo "⚠️ No APP_KEY and no .env! Generating dummy key so server starts..."
   echo "APP_KEY=base64:$(openssl rand -base64 32)" >> .env
fi

# Force logs to stderr for container visibility
if ! grep -q "LOG_CHANNEL=stderr" .env 2>/dev/null; then
    echo "LOG_CHANNEL=stderr" >> .env
fi

# Fix permissions (storage must be writable)
echo "🔒 Fixing permissions..."
chmod -R 755 storage bootstrap/cache 2>/dev/null || true

# Ensure storage symlink exists
php artisan storage:link 2>/dev/null || true

# Determine port (Railway sets PORT env var)
PORT="${PORT:-8080}"
echo "🔌 Starting PHP built-in server on port $PORT..."

# Start PHP's built-in server
# Note: For production, you might want to use php-fpm + nginx or frankenphp
exec php artisan serve --host=0.0.0.0 --port="$PORT"
