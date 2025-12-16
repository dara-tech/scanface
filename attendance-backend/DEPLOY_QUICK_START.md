# 🚀 Quick Start: Deploy to Render

## Prerequisites Checklist
- [ ] MongoDB Atlas account (free tier)
- [ ] Render account (free tier available)
- [ ] GitHub repository with your code

## Step-by-Step Deployment

### 1. Set Up MongoDB Atlas (5 minutes)

1. Go to https://www.mongodb.com/cloud/atlas → Sign up (free)
2. Create a cluster → Choose **FREE** tier
3. Wait for cluster creation (~3 minutes)
4. Click **"Connect"** → **"Connect your application"**
5. Copy connection string:
   ```
   mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/attendance_app?retryWrites=true&w=majority
   ```
6. Replace `<username>` and `<password>` with your database user credentials
7. **Important:** In MongoDB Atlas → Network Access → Add IP Address → Add `0.0.0.0/0` (allow all IPs for Render)

### 2. Deploy to Render (10 minutes)

1. **Push code to GitHub** (if not already):
   ```bash
   git add .
   git commit -m "Ready for Render deployment"
   git push origin main
   ```

2. **Create Web Service on Render:**
   - Go to https://dashboard.render.com
   - Click **"New +"** → **"Web Service"**
   - Connect GitHub → Select your repository
   - **Root Directory:** `attendance-backend` (if repo root is parent folder)
   - **Name:** `attendance-backend`
   - **Environment:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`

3. **Add Environment Variables:**
   ```
   NODE_ENV=production
   PORT=10000
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/attendance_app?retryWrites=true&w=majority
   JWT_SECRET=generate-a-random-32-character-string-here
   JWT_EXPIRES_IN=7d
   CORS_ORIGIN=*
   SERVER_URL=https://your-app-name.onrender.com
   ```
   
   **Note:** `SERVER_URL` enables auto-ping to keep server alive (pings every 14 minutes).

4. **Deploy:**
   - Click **"Create Web Service"**
   - Wait 2-5 minutes for deployment
   - Copy your URL: `https://your-app-name.onrender.com`

### 3. Update Flutter App

Edit `lib/config/api_config.dart`:

**Option A: Use manual override (easiest for testing)**
```dart
static const String? manualBaseUrl = 'https://your-app-name.onrender.com/api';
static const String? manualSocketUrl = 'https://your-app-name.onrender.com';
```

**Option B: Use production URLs (for release builds)**
```dart
static const String? productionBaseUrl = 'https://your-app-name.onrender.com/api';
static const String? productionSocketUrl = 'https://your-app-name.onrender.com';
```

### 4. Create Admin Account

After deployment, create an admin:
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

### 5. Test It!

```bash
# Health check
curl https://your-app-name.onrender.com/health

# Should return: {"status":"ok","database":"connected",...}
```

## Common Issues

**❌ Deployment fails:**
- Check build logs in Render dashboard
- Ensure `package.json` has `start` script

**❌ Database connection fails:**
- Verify MongoDB Atlas IP whitelist includes `0.0.0.0/0`
- Check connection string is correct
- Ensure username/password are correct

**❌ App can't connect:**
- Verify Render URL is correct
- Check CORS_ORIGIN setting
- Ensure HTTPS is used (not HTTP)

## Next Steps

- [ ] Test all API endpoints
- [ ] Create admin account
- [ ] Update Flutter app with Render URL
- [ ] Test login from Flutter app
- [ ] (Optional) Set up custom domain

## Need Help?

See full guide: `RENDER_DEPLOYMENT.md`

