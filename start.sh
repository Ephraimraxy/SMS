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

# Cache configuration (now that env vars are available)
echo "⚙️ Caching configuration..."
php artisan config:cache || echo "⚠️ Config cache failed"
php artisan route:cache || echo "⚠️ Route cache failed"
php artisan view:cache || echo "⚠️ View cache failed"

# Fallback for APP_KEY if it's still empty (prevent boot loop)
if [ -z "$APP_KEY" ] && [ ! -f .env ]; then
   echo "⚠️ No APP_KEY and no .env! Generating dummy key so Apache starts..."
   echo "APP_KEY=base64:$(openssl rand -base64 32)" >> .env
fi

# Clear any stale caches
php artisan cache:clear || true

# Configure Apache port if PORT env var is set
if [ -n "${PORT:-}" ]; then
    echo "🔌  Configuring Apache to listen on PORT=$PORT (and also 80 for compatibility)..."

    # Railway (and other platforms) sometimes route traffic to the Dockerfile's exposed port (often 80)
    # even while setting $PORT to a different value. Listening on both avoids 503 healthcheck failures.
    if ! grep -qE '^[[:space:]]*Listen[[:space:]]+80[[:space:]]*$' /etc/apache2/ports.conf; then
        echo "Listen 80" >> /etc/apache2/ports.conf
    fi

    if [ "$PORT" != "80" ]; then
        if ! grep -qE "^[[:space:]]*Listen[[:space:]]+$PORT[[:space:]]*$" /etc/apache2/ports.conf; then
            echo "Listen $PORT" >> /etc/apache2/ports.conf
        fi

        # Make the default vhost respond on both ports.
        # Replace any existing <VirtualHost ...> line with one that includes 80 and $PORT.
        sed -i -E "s#<VirtualHost[^>]*>#<VirtualHost *:80 *:$PORT>#g" /etc/apache2/sites-available/000-default.conf
    fi
else
    echo "⚠️  PORT variable not set, defaulting to 80"
fi

echo "✅ Startup complete! Preparing web server..."

# Ensure only one Apache MPM is enabled to avoid:
#   AH00534: apache2: Configuration error: More than one MPM loaded.
if command -v a2dismod >/dev/null 2>&1; then
    echo "🔧 Ensuring a single Apache MPM (prefork) is enabled..."
    # Disable alternative MPMs if present (ignore errors if they don't exist)
    a2dismod mpm_event mpm_worker mpm_prefork 2>/dev/null || true
    a2enmod mpm_prefork 2>/dev/null || true
fi

echo "🚀 Starting Apache (apache2-foreground)..."
exec apache2-foreground
