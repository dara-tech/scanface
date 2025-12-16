# 🚀 Deploying to Render

This guide will help you deploy your attendance backend to Render.

## Prerequisites

1. **MongoDB Atlas Account** (Free tier available)
   - Sign up at https://www.mongodb.com/cloud/atlas
   - Create a free cluster
   - Get your connection string

2. **Render Account**
   - Sign up at https://render.com
   - Connect your GitHub account (recommended)

## Step 1: Set Up MongoDB Atlas

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free account
3. Create a new cluster (choose the free tier)
4. Wait for the cluster to be created (takes a few minutes)
5. Click **"Connect"** on your cluster
6. Choose **"Connect your application"**
7. Copy the connection string (it will look like):
   ```
   mongodb+srv://username:password@cluster.mongodb.net/attendance_app?retryWrites=true&w=majority
   ```
8. Replace `<password>` with your database user password
9. Replace `attendance_app` with your database name (or keep it)

## Step 2: Deploy to Render

### Option A: Using Render Dashboard (Recommended)

1. **Push your code to GitHub**
   ```bash
   git add .
   git commit -m "Prepare for Render deployment"
   git push origin main
   ```

2. **Create a new Web Service on Render**
   - Go to https://dashboard.render.com
   - Click **"New +"** → **"Web Service"**
   - Connect your GitHub repository
   - Select the `attendance-backend` folder

3. **Configure the service:**
   - **Name:** `attendance-backend` (or your preferred name)
   - **Environment:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Root Directory:** `attendance-backend` (if your repo root is the parent folder)

4. **Set Environment Variables:**
   Click **"Environment"** tab and add:
   ```
   NODE_ENV=production
   PORT=10000
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/attendance_app?retryWrites=true&w=majority
   JWT_SECRET=your-super-secret-jwt-key-min-32-characters-long
   JWT_EXPIRES_IN=7d
   CORS_ORIGIN=*
   ```

5. **Deploy**
   - Click **"Create Web Service"**
   - Render will build and deploy your app
   - Wait for deployment to complete (usually 2-5 minutes)

6. **Get your Render URL**
   - After deployment, you'll get a URL like: `https://attendance-backend.onrender.com`
   - Copy this URL - you'll need it for your Flutter app

### Option B: Using render.yaml (Advanced)

1. Make sure `render.yaml` is in your `attendance-backend` folder
2. Push to GitHub
3. On Render dashboard, create a new **"Blueprint"**
4. Connect your repository
5. Render will automatically detect `render.yaml` and configure the service

## Step 3: Update Flutter App Configuration

After deployment, update your Flutter app to use the Render URL:

1. **Update `lib/config/api_config.dart`:**

```dart
class ApiConfig {
  // Production URL (Render)
  static const String? productionBaseUrl = 'https://your-app-name.onrender.com/api';
  static const String? productionSocketUrl = 'https://your-app-name.onrender.com';
  
  // Manual override - set this if automatic detection doesn't work
  static const String? manualBaseUrl = null; // Set to productionBaseUrl for production
  static const String? manualSocketUrl = null; // Set to productionSocketUrl for production
  
  static String get baseUrl {
    // Manual override takes priority
    if (manualBaseUrl != null) {
      return manualBaseUrl!;
    }
    
    // Use production URL if in release mode
    if (kReleaseMode && productionBaseUrl != null) {
      return productionBaseUrl!;
    }
    
    // ... rest of your existing code
  }
  
  static String get socketUrl {
    // Manual override takes priority
    if (manualSocketUrl != null) {
      return manualSocketUrl!;
    }
    
    // Use production URL if in release mode
    if (kReleaseMode && productionSocketUrl != null) {
      return productionSocketUrl!;
    }
    
    // ... rest of your existing code
  }
}
```

2. **Or use manual override for testing:**
   ```dart
   static const String? manualBaseUrl = 'https://your-app-name.onrender.com/api';
   static const String? manualSocketUrl = 'https://your-app-name.onrender.com';
   ```

## Step 4: Test Your Deployment

1. **Health Check:**
   ```bash
   curl https://your-app-name.onrender.com/health
   ```
   Should return: `{"status":"ok","database":"connected",...}`

2. **Test Registration:**
   ```bash
   curl -X POST https://your-app-name.onrender.com/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Test User",
       "email": "test@example.com",
       "password": "test123",
       "role": "employee"
     }'
   ```

3. **Test Login:**
   ```bash
   curl -X POST https://your-app-name.onrender.com/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "test123"
     }'
   ```

## Step 5: Create Admin Account

After deployment, create an admin account:

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

## Important Notes

### Free Tier Limitations

Render's free tier has some limitations:
- **Spins down after 15 minutes of inactivity** - First request after spin-down takes ~30 seconds
- **512 MB RAM** - Should be enough for this app
- **Limited CPU** - May be slower during high traffic

### WebSocket on Render

Render supports WebSocket connections, but you may need to:
- Ensure your Socket.io client connects to the HTTPS URL
- Check that CORS is properly configured

### CORS Configuration

For production, update `CORS_ORIGIN` to only allow your Flutter app:
```
CORS_ORIGIN=https://your-flutter-app.com,https://www.your-flutter-app.com
```

Or if your Flutter app doesn't have a domain, you can keep it as `*` (less secure but works for mobile apps).

### Environment Variables Security

- **Never commit `.env` file to Git**
- Use Render's environment variables section
- Generate a strong `JWT_SECRET` (at least 32 characters)
- Keep your MongoDB Atlas password secure

## Troubleshooting

### Deployment Fails

1. Check build logs in Render dashboard
2. Ensure all dependencies are in `package.json`
3. Verify `start` script exists in `package.json`

### Database Connection Fails

1. Check MongoDB Atlas IP whitelist (add `0.0.0.0/0` for Render)
2. Verify connection string is correct
3. Check MongoDB user has proper permissions

### App Returns 404

1. Verify routes are correct
2. Check that API calls use `/api/` prefix
3. Test health endpoint first: `/health`

### WebSocket Not Working

1. Ensure Socket.io client uses HTTPS URL
2. Check CORS configuration
3. Verify WebSocket is enabled in Render (should be by default)

## Next Steps

1. ✅ Deploy backend to Render
2. ✅ Update Flutter app with Render URL
3. ✅ Test all API endpoints
4. ✅ Create admin account
5. ⏭️ Set up custom domain (optional)
6. ⏭️ Configure SSL (automatic with Render)
7. ⏭️ Set up monitoring and alerts

## Support

- Render Docs: https://render.com/docs
- MongoDB Atlas Docs: https://docs.atlas.mongodb.com
- Socket.io Docs: https://socket.io/docs

