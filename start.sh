#!/bin/bash
set -e

echo "🚀 Starting Laravel School Management System..."

# Copy .env if not exists
if [ ! -f ".env" ]; then
    echo "⚠️ .env not found, copying from .env.example..."
    cp .env.example .env 2>/dev/null || echo "No .env.example found"
fi

# CRITICAL: Generate APP_KEY if not set in environment or .env
if [ -z "$APP_KEY" ]; then
    echo "⚠️ APP_KEY not set in environment, generating one..."
    # Generate key and extract it
    php artisan key:generate --show > /tmp/appkey.txt 2>/dev/null || true
    GENERATED_KEY=$(cat /tmp/appkey.txt 2>/dev/null | head -1)
    
    if [ -n "$GENERATED_KEY" ]; then
        export APP_KEY="$GENERATED_KEY"
        echo "APP_KEY=$GENERATED_KEY" >> .env
        echo "✅ Generated APP_KEY: ${GENERATED_KEY:0:20}..."
    else
        # Fallback: generate with openssl
        RANDOM_KEY=$(openssl rand -base64 32)
        export APP_KEY="base64:$RANDOM_KEY"
        echo "APP_KEY=base64:$RANDOM_KEY" >> .env
        echo "✅ Generated fallback APP_KEY"
    fi
fi

# Ensure .env has the APP_KEY (even if it was set via environment)
if ! grep -q "^APP_KEY=" .env 2>/dev/null; then
    echo "APP_KEY=$APP_KEY" >> .env
fi

# Run database migrations (don't fail if DB isn't ready)
echo "📦 Running database migrations..."
php artisan migrate --force 2>/dev/null || echo "⚠️ Migrations skipped (DB may not be ready)"

# Clear and cache config
echo "🧹 Clearing caches..."
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan view:clear 2>/dev/null || true

# Fix permissions
echo "🔒 Fixing permissions..."
chmod -R 755 storage bootstrap/cache 2>/dev/null || true

# Create storage symlink (ignore if exists)
php artisan storage:link 2>/dev/null || true

# Force logs to stderr for Railway visibility
if ! grep -q "^LOG_CHANNEL=" .env 2>/dev/null; then
    echo "LOG_CHANNEL=stderr" >> .env
fi

# Determine port (Railway sets PORT env var)
PORT="${PORT:-8080}"
echo "🔌 Starting PHP built-in server on port $PORT..."

# Start PHP's built-in server
exec php artisan serve --host=0.0.0.0 --port="$PORT"
