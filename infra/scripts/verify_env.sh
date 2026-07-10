#!/bin/sh
# infra/scripts/verify_env.sh

ENV_FILE="frontend/.env.development"
REQUIRED_KEYS="SUPABASE_URL SUPABASE_ANON_KEY AI_GATEWAY_URL LIVEKIT_URL REVENUECAT_API_KEY"

echo "===================================================="
echo "Verifying environment configuration..."
echo "Target File: $ENV_FILE"
echo "===================================================="

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ ERROR: Environment file $ENV_FILE does not exist!"
  echo "Please copy frontend/lib/config/.env.example and populate keys."
  exit 1
fi

FAILED=0
for key in $REQUIRED_KEYS; do
  if grep -q "^$key=" "$ENV_FILE"; then
    val=$(grep "^$key=" "$ENV_FILE" | cut -d'=' -f2-)
    if [ -z "$val" ]; then
      echo "❌ FAILED: Key '$key' is empty!"
      FAILED=1
    else
      echo "✅ PASSED: Key '$key' is configured."
    fi
  else
    echo "❌ FAILED: Key '$key' is missing from file!"
    FAILED=1
  fi
done

echo "===================================================="
if [ $FAILED -eq 1 ]; then
  echo "❌ Configuration check failed! Please fix the errors listed above."
  exit 1
else
  echo "✅ Configuration check passed successfully! You are ready to develop."
  exit 0
fi
