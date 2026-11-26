#!/usr/bin/env bash
# Build para Render (Static Site): genera dist/ con index.html y config.js
set -euo pipefail
: "${SUPABASE_URL:?Falta la variable de entorno SUPABASE_URL}"
: "${SUPABASE_KEY:?Falta la variable de entorno SUPABASE_KEY}"
rm -rf dist && mkdir -p dist
cp index.html calidad.html dist/
cat > dist/config.js <<EOF
window.APP_CONFIG = { SUPABASE_URL: "${SUPABASE_URL}", SUPABASE_KEY: "${SUPABASE_KEY}" };
EOF
echo "Build OK -> dist/"
