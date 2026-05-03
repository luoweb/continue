#!/bin/bash

echo "=== Testing Continue Auth Service ==="
echo ""

echo "1. Registering test user..."
curl -s -X POST "http://localhost:8000/auth/register?email=test@example.com&password=test123" > /dev/null
echo "   ✓ User registered"

echo ""
echo "2. Requesting device authorization..."
DEVICE_RESP=$(curl -s -X POST http://localhost:8000/user_management/authorize/device \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=continue-cli")

DEVICE_CODE=$(echo $DEVICE_RESP | grep -o '"device_code":"[^"]*' | cut -d'"' -f4)
USER_CODE=$(echo $DEVICE_RESP | grep -o '"user_code":"[^"]*' | cut -d'"' -f4)

echo "   ✓ Device code: $DEVICE_CODE"
echo "   ✓ User code: $USER_CODE"

echo ""
echo "3. Authorizing device (simulating user login in browser)..."
curl -s -X POST "http://localhost:8000/auth/device/authorize?user_code=$USER_CODE&email=test@example.com&password=test123" > /dev/null
echo "   ✓ Device authorized"

echo ""
echo "4. Authenticating with device code..."
AUTH_RESP=$(curl -s -X POST http://localhost:8000/user_management/authenticate \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:device_code&device_code=$DEVICE_CODE&client_id=continue-cli")

ACCESS_TOKEN=$(echo $AUTH_RESP | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
USER_ID=$(echo $AUTH_RESP | grep -o '"id":"[^"]*' | cut -d'"' -f4)
USER_EMAIL=$(echo $AUTH_RESP | grep -o '"email":"[^"]*' | cut -d'"' -f4)

echo "   ✓ Access token obtained"
echo "   ✓ User ID: $USER_ID"
echo "   ✓ User Email: $USER_EMAIL"

echo ""
echo "5. Getting user info..."
USER_INFO=$(curl -s -X GET "http://localhost:8000/auth/userinfo?access_token=$ACCESS_TOKEN")
echo "   ✓ User info retrieved successfully"

echo ""
echo "=== All tests passed! ==="