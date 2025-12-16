#!/bin/bash

# API Testing Script
BASE_URL="http://localhost:3000/api"

echo "🧪 Testing Attendance Backend API"
echo "=================================="
echo ""

# Test 1: Health Check
echo "1️⃣ Testing Health Check..."
HEALTH=$(curl -s http://localhost:3000/health)
echo "$HEALTH" | python3 -m json.tool 2>/dev/null || echo "$HEALTH"
echo ""

# Test 2: Register User
echo "2️⃣ Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test'$(date +%s)'@test.com",
    "password": "password123",
    "role": "employee"
  }')

echo "$REGISTER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$REGISTER_RESPONSE"

# Extract token
TOKEN=$(echo "$REGISTER_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('token', ''))" 2>/dev/null)
USER_ID=$(echo "$REGISTER_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('user', {}).get('_id', ''))" 2>/dev/null)

echo ""
if [ -z "$TOKEN" ]; then
  echo "❌ Registration failed or user already exists"
  echo ""
  echo "3️⃣ Trying Login instead..."
  LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
      "email": "test@test.com",
      "password": "password123"
    }')
  
  echo "$LOGIN_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$LOGIN_RESPONSE"
  TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('token', ''))" 2>/dev/null)
  USER_ID=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('user', {}).get('_id', ''))" 2>/dev/null)
else
  echo "✅ Registration successful!"
  echo "Token: ${TOKEN:0:50}..."
fi

echo ""

if [ -n "$TOKEN" ]; then
  # Test 3: Get Current User
  echo "3️⃣ Testing Get Current User..."
  CURRENT_USER=$(curl -s -X GET "$BASE_URL/auth/me" \
    -H "Authorization: Bearer $TOKEN")
  echo "$CURRENT_USER" | python3 -m json.tool 2>/dev/null || echo "$CURRENT_USER"
  echo ""

  # Test 4: Check-In
  echo "4️⃣ Testing Check-In..."
  CHECKIN_RESPONSE=$(curl -s -X POST "$BASE_URL/attendance/checkin" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "location": {
        "latitude": 37.7749,
        "longitude": -122.4194
      }
    }')
  
  echo "$CHECKIN_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$CHECKIN_RESPONSE"
  
  ATTENDANCE_ID=$(echo "$CHECKIN_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('attendance', {}).get('_id', ''))" 2>/dev/null)
  echo ""

  # Test 5: Get Today's Attendance
  echo "5️⃣ Testing Get Today's Attendance..."
  TODAY_ATTENDANCE=$(curl -s -X GET "$BASE_URL/attendance/today" \
    -H "Authorization: Bearer $TOKEN")
  echo "$TODAY_ATTENDANCE" | python3 -m json.tool 2>/dev/null || echo "$TODAY_ATTENDANCE"
  echo ""

  # Test 6: Check-Out (if attendance ID exists)
  if [ -n "$ATTENDANCE_ID" ]; then
    echo "6️⃣ Testing Check-Out..."
    CHECKOUT_RESPONSE=$(curl -s -X PUT "$BASE_URL/attendance/$ATTENDANCE_ID/checkout" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "location": {
          "latitude": 37.7749,
          "longitude": -122.4194
        }
      }')
    
    echo "$CHECKOUT_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$CHECKOUT_RESPONSE"
    echo ""
  fi

  # Test 7: Get Attendance Stats
  echo "7️⃣ Testing Attendance Statistics..."
  STATS=$(curl -s -X GET "$BASE_URL/attendance/stats" \
    -H "Authorization: Bearer $TOKEN")
  echo "$STATS" | python3 -m json.tool 2>/dev/null || echo "$STATS"
  echo ""

  echo "✅ All tests completed!"
else
  echo "❌ Could not get authentication token. Please check:"
  echo "   1. Backend server is running (npm run dev)"
  echo "   2. MongoDB is connected"
  echo "   3. User doesn't already exist (try different email)"
fi

