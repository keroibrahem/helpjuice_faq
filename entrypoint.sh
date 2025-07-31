#!/bin/bash
set -e

echo "🔧 Precompiling assets..."
bundle exec rails assets:precompile

echo "🔄 Running database migrations..."
bundle exec rails db:migrate

echo "🚀 Starting the server..."
exec "$@"

