# 🚀 Complete Deployment Guide: From Local to Render

This is a comprehensive step-by-step guide to deploy your attendance app backend to Render and connect your Flutter app.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Set Up MongoDB Atlas](#step-1-set-up-mongodb-atlas)
3. [Step 2: Prepare Your Code](#step-2-prepare-your-code)
4. [Step 3: Deploy to Render](#step-3-deploy-to-render)
5. [Step 4: Update Flutter App](#step-4-update-flutter-app)
6. [Step 5: Test Everything](#step-5-test-everything)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, make sure you have:

- ✅ GitHub account (you already have: `dara-tech`)
- ✅ Code pushed to GitHub (already done: `https://github.com/dara-tech/scanface.git`)
- ⏳ MongoDB Atlas account (we'll create this)
- ⏳ Render account (we'll create this)

---

## Step 1: Set Up MongoDB Atlas

MongoDB Atlas is a cloud database service. We'll use the free tier.

### 1.1 Create MongoDB Atlas Account

1. Go to **https://www.mongodb.com/cloud/atlas**
2. Click **"Try Free"** or **"Sign Up"**
3. Fill in your details:
   - Email
   - Password
   - Company (optional)
4. Click **"Create account"**
5. Verify your email if prompted

### 1.2 Create a Free Cluster

1. After logging in, you'll see the **"Deploy a cloud database"** screen
2. Choose **"M0 FREE"** tier (Free forever)
3. Select a **Cloud Provider**:
   - AWS (recommended)
   - Google Cloud
   - Azure
4. Select a **Region** closest to you (e.g., `N. Virginia (us-east-1)`)
5. Click **"Create"**
6. ⏳ Wait 3-5 minutes for cluster creation

### 1.3 Create Database User

1. While cluster is creating, you'll see **"Create Database User"** screen
2. Choose **"Username and Password"** authentication
3. Enter:
   - **Username:** `attendance_user` (or your choice)
   - **Password:** Click **"Autogenerate Secure Password"** or create your own
   - ⚠️ **IMPORTANT:** Save this password! Copy it somewhere safe.
4. Click **"Create Database User"**

### 1.4 Configure Network Access

1. You'll see **"Where would you like to connect from?"** screen
2. For Render deployment, we need to allow all IPs:
   - Click **"Add My Current IP Address"** (for testing)
   - Then click **"Add IP Address"** again
   - Enter: `0.0.0.0/0` (allows all IPs - needed for Render)
   - Description: `Render and all IPs`
   - Click **"Confirm"**
3. Click **"Finish and Close"**

### 1.5 Get Connection String

1. Once cluster is ready, click **"Connect"** button
2. Choose **"Connect your application"**
3. Select **"Node.js"** as driver
4. Copy the connection string - it looks like:
   ```
   mongodb+srv://attendance_user:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
5. **Replace `<password>`** with your actual password
6. **Add database name** at the end:
   ```
   mongodb+srv://attendance_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/attendance_app?retryWrites=true&w=majority
   ```
7. ⚠️ **Save this complete connection string** - you'll need it for Render!

**Example:**
```
mongodb+srv://attendance_user:MySecurePass123@cluster0.abc123.mongodb.net/attendance_app?retryWrites=true&w=majority
```

---

## Step 2: Prepare Your Code

Your code is already on GitHub, but let's verify everything is ready.

### 2.1 Verify GitHub Repository

1. Go to **https://github.com/dara-tech/scanface**
2. Verify you can see:
   - ✅ `attendance-backend/` folder
   - ✅ `lib/` folder (Flutter code)
   - ✅ `package.json` in `attendance-backend/`
   - ✅ `.env.example` in `attendance-backend/`

### 2.2 Generate JWT Secret (Optional but Recommended)

You'll need a secure JWT secret for production. Generate one:

**Option A: Using Node.js**
```bash
cd attendance-backend
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**Option B: Using Online Tool**
- Go to https://randomkeygen.com/
- Copy a "CodeIgniter Encryption Keys" (32+ characters)

**Option C: Manual**
- Create a random 32+ character string
- Example: `my-super-secret-jwt-key-2024-production-xyz123`

⚠️ **Save this JWT secret** - you'll need it for Render!

---

## Step 3: Deploy to Render

### 3.1 Create Render Account

1. Go to **https://render.com**
2. Click **"Get Started for Free"**
3. Sign up with:
   - **GitHub** (recommended - connects automatically)
   - Or Email
4. Complete signup process

### 3.2 Create New Web Service

1. In Render dashboard, click **"New +"** button (top right)
2. Select **"Web Service"**
3. Connect your repository:
   - If using GitHub OAuth: Select **"dara-tech/scanface"**
   - If using Git: Enter `https://github.com/dara-tech/scanface.git`
4. Click **"Connect"**

### 3.3 Configure Web Service

Fill in the following settings:

**Basic Settings:**
- **Name:** `attendance-backend` (or your choice)
- **Region:** Choose closest to you (e.g., `Oregon (US West)`)
- **Branch:** `main` (or `master` if that's your default)
- **Root Directory:** `attendance-backend` ⚠️ **IMPORTANT!**
- **Runtime:** `Node`
- **Build Command:** `npm install`
- **Start Command:** `npm start`

**Advanced Settings (click to expand):**
- **Auto-Deploy:** `Yes` (deploys automatically on git push)
- **Health Check Path:** `/health` (optional but recommended)

### 3.4 Add Environment Variables

Click **"Environment"** tab and add these variables:

| Key | Value | Notes |
|-----|-------|-------|
| `NODE_ENV` | `production` | Required |
| `PORT` | `10000` | Render uses port 10000 |
| `MONGODB_URI` | `mongodb+srv://...` | Your MongoDB Atlas connection string from Step 1.5 |
| `JWT_SECRET` | `your-32-char-secret` | The JWT secret from Step 2.2 |
| `JWT_EXPIRES_IN` | `7d` | Token expiration (7 days) |
| `CORS_ORIGIN` | `*` | Allows all origins (for mobile apps) |

**How to add:**
1. Click **"Add Environment Variable"**
2. Enter **Key** and **Value**
3. Click **"Save Changes"**
4. Repeat for each variable

⚠️ **Important:** 
- Make sure `MONGODB_URI` includes your password and database name
- `JWT_SECRET` should be at least 32 characters
- Double-check all values before saving

### 3.5 Deploy

1. Review all settings
2. Scroll down and click **"Create Web Service"**
3. ⏳ Wait 2-5 minutes for deployment
4. Watch the build logs - you should see:
   - ✅ Installing dependencies
   - ✅ Building...
   - ✅ Starting service
   - ✅ MongoDB Connected

### 3.6 Get Your Render URL

After successful deployment:

1. You'll see a URL like: `https://attendance-backend.onrender.com`
2. ⚠️ **Copy this URL** - you'll need it for your Flutter app!
3. Test it: Click the URL or run:
   ```bash
   curl https://your-app-name.onrender.com/health
   ```
   Should return: `{"status":"ok","database":"connected",...}`

---

## Step 4: Update Flutter App

Now we'll update your Flutter app to use the Render URL.

### 4.1 Update API Configuration

1. Open `lib/config/api_config.dart`
2. Find the `manualBaseUrl` and `manualSocketUrl` constants
3. Update them with your Render URL:

```dart
// Replace 'your-app-name' with your actual Render app name
static const String? manualBaseUrl = 'https://your-app-name.onrender.com/api';
static const String? manualSocketUrl = 'https://your-app-name.onrender.com';
```

**Example:**
```dart
static const String? manualBaseUrl = 'https://attendance-backend.onrender.com/api';
static const String? manualSocketUrl = 'https://attendance-backend.onrender.com';
```

### 4.2 Alternative: Use Production URLs (For Release Builds)

If you want to use different URLs for debug vs release:

```dart
// Production URLs (for release builds)
static const String? productionBaseUrl = 'https://your-app-name.onrender.com/api';
static const String? productionSocketUrl = 'https://your-app-name.onrender.com';

// Manual override (for testing)
static const String? manualBaseUrl = null; // Set to production URL for testing
```

### 4.3 Test the Connection

1. Save the file
2. Hot reload your Flutter app (press `r` in terminal or restart)
3. Try to login or register
4. Check if it connects to Render backend

---

## Step 5: Test Everything

### 5.1 Test Backend Health

```bash
curl https://your-app-name.onrender.com/health
```

**Expected response:**
```json
{
  "status": "ok",
  "timestamp": "2024-12-16T...",
  "database": "connected"
}
```

### 5.2 Create Admin Account

```bash
curl -X POST https://your-app-name.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin User",
    "email": "admin@example.com",
    "password": "admin123",
    "role": "admin"
  }'
```

**Expected response:**
```json
{
  "message": "User registered successfully",
  "user": {...},
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

### 5.3 Test Login

```bash
curl -X POST https://your-app-name.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }'
```

**Expected response:**
```json
{
  "message": "Login successful",
  "user": {...},
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

### 5.4 Test from Flutter App

1. Open your Flutter app
2. Try to register a new account
3. Try to login
4. Verify everything works

---

## Troubleshooting

### ❌ Deployment Fails

**Problem:** Build fails on Render

**Solutions:**
1. Check build logs in Render dashboard
2. Verify `package.json` has `start` script:
   ```json
   "scripts": {
     "start": "node src/server.js"
   }
   ```
3. Ensure `Root Directory` is set to `attendance-backend`
4. Check that all dependencies are in `package.json`

### ❌ Database Connection Fails

**Problem:** `database: "disconnected"` in health check

**Solutions:**
1. Verify MongoDB Atlas IP whitelist includes `0.0.0.0/0`
2. Check connection string format:
   - Must include password
   - Must include database name: `/attendance_app`
   - No spaces or special characters
3. Test connection string locally:
   ```bash
   mongosh "mongodb+srv://..."
   ```
4. Verify MongoDB user has read/write permissions

### ❌ App Can't Connect to Backend

**Problem:** Flutter app shows connection error

**Solutions:**
1. Verify Render URL is correct (HTTPS, not HTTP)
2. Check `manualBaseUrl` in `api_config.dart`
3. Test Render URL in browser: `https://your-app.onrender.com/health`
4. Check CORS settings (should be `*` for mobile apps)
5. Verify backend is running (check Render dashboard)

### ❌ "Invalid email or password" Error

**Problem:** Login fails even with correct credentials

**Solutions:**
1. Create a new account via API (see Step 5.2)
2. Verify password is being hashed correctly
3. Check MongoDB has users collection
4. Try registering a new account first

### ❌ Render App Spins Down

**Problem:** First request takes 30+ seconds

**Explanation:** Render free tier spins down after 15 minutes of inactivity

**Solutions:**
1. This is normal for free tier
2. First request after spin-down takes ~30 seconds
3. Subsequent requests are fast
4. Consider upgrading to paid plan for always-on

### ❌ WebSocket Not Working

**Problem:** Real-time features don't work

**Solutions:**
1. Verify Socket.io URL uses HTTPS
2. Check `manualSocketUrl` in `api_config.dart`
3. Ensure CORS allows WebSocket connections
4. Test WebSocket connection separately

---

## 🎉 Success Checklist

After completing all steps, you should have:

- ✅ MongoDB Atlas cluster running
- ✅ Backend deployed on Render
- ✅ Render URL working (health check passes)
- ✅ Admin account created
- ✅ Flutter app connecting to Render backend
- ✅ Login/Registration working from Flutter app

---

## 📝 Next Steps

1. **Custom Domain** (Optional)
   - Add your own domain in Render settings
   - Update Flutter app with new domain

2. **Environment-Specific Configs**
   - Use different URLs for dev/staging/production
   - Set up separate MongoDB databases

3. **Monitoring**
   - Set up Render alerts
   - Monitor MongoDB Atlas metrics
   - Add logging service

4. **Security**
   - Restrict CORS to specific domains
   - Use stronger JWT secrets
   - Enable MongoDB Atlas authentication

5. **Scaling**
   - Upgrade Render plan for better performance
   - Add MongoDB Atlas monitoring
   - Set up CI/CD pipeline

---

## 📚 Additional Resources

- **Render Docs:** https://render.com/docs
- **MongoDB Atlas Docs:** https://docs.atlas.mongodb.com
- **Socket.io Docs:** https://socket.io/docs
- **Flutter HTTP:** https://docs.flutter.dev/cookbook/networking

---

## 🆘 Need Help?

If you encounter issues:

1. Check the **Troubleshooting** section above
2. Review Render build logs
3. Check MongoDB Atlas connection logs
4. Verify all environment variables are set correctly
5. Test API endpoints with curl commands

---

**Good luck with your deployment! 🚀**

