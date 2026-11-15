#!/bin/sh
# Copia la clave de Google Maps de .env a la configuración nativa de iOS (Android la lee directo de .env).
cd "$(dirname "$0")/.." || exit 1
KEY=$(grep -E '^EXPO_PUBLIC_GOOGLE_MAPS_API_KEY=' .env | cut -d= -f2-)
echo "GOOGLE_MAPS_API_KEY=$KEY" > ios/Flutter/Env.xcconfig
echo "Env.xcconfig actualizado"
