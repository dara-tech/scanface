# ✅ Deployment Checklist

Use this checklist to track your deployment progress.

## 📋 Pre-Deployment

- [ ] Code pushed to GitHub (`dara-tech/scanface`)
- [ ] `.env` file is NOT in repository (checked in `.gitignore`)
- [ ] `.env.example` exists in `attendance-backend/`
- [ ] `package.json` has `start` script
- [ ] Backend runs locally without errors

## 🗄️ MongoDB Atlas Setup

- [ ] Created MongoDB Atlas account
- [ ] Created M0 FREE cluster
- [ ] Created database user (username + password saved)
- [ ] Network Access configured:
  - [ ] Added current IP
  - [ ] Added `0.0.0.0/0` (all IPs for Render)
- [ ] Connection string copied and formatted correctly:
  - [ ] Includes password
  - [ ] Includes database name (`/attendance_app`)
  - [ ] Format: `mongodb+srv://user:pass@cluster.net/attendance_app?...`

## 🚀 Render Deployment

- [ ] Created Render account
- [ ] Created new Web Service
- [ ] Connected GitHub repository (`dara-tech/scanface`)
- [ ] Configuration set:
  - [ ] Name: `attendance-backend`
  - [ ] Root Directory: `attendance-backend` ⚠️
  - [ ] Build Command: `npm install`
  - [ ] Start Command: `npm start`
- [ ] Environment Variables added:
  - [ ] `NODE_ENV=production`
  - [ ] `PORT=10000`
  - [ ] `MONGODB_URI=...` (complete connection string)
  - [ ] `JWT_SECRET=...` (32+ characters)
  - [ ] `JWT_EXPIRES_IN=7d`
  - [ ] `CORS_ORIGIN=*`
- [ ] Deployment successful
- [ ] Render URL copied: `https://...onrender.com`

## 🧪 Testing

- [ ] Health check works: `curl https://...onrender.com/health`
- [ ] Database shows "connected" in health response
- [ ] Admin account created via API
- [ ] Login test successful via API
- [ ] Flutter app updated with Render URL
- [ ] Flutter app connects to Render backend
- [ ] Login works from Flutter app
- [ ] Registration works from Flutter app

## 📱 Flutter App Update

- [ ] Opened `lib/config/api_config.dart`
- [ ] Updated `manualBaseUrl` with Render URL
- [ ] Updated `manualSocketUrl` with Render URL
- [ ] Saved file
- [ ] App restarted/hot reloaded
- [ ] Tested connection from app

## 🎉 Final Verification

- [ ] All API endpoints working
- [ ] WebSocket connections working (if applicable)
- [ ] No errors in Render logs
- [ ] No errors in Flutter app
- [ ] Can create users
- [ ] Can login
- [ ] Can perform attendance operations

---

## 📝 Important URLs to Save

**MongoDB Atlas:**
- Cluster URL: `https://cloud.mongodb.com/...`
- Connection String: `mongodb+srv://...`

**Render:**
- Dashboard: `https://dashboard.render.com`
- App URL: `https://...onrender.com`
- Health Check: `https://...onrender.com/health`

**GitHub:**
- Repository: `https://github.com/dara-tech/scanface`

---

## 🔑 Credentials to Save Securely

- MongoDB Username: `_________________`
- MongoDB Password: `_________________`
- JWT Secret: `_________________`
- Render App URL: `_________________`

⚠️ **Never commit these to Git!**

---

## 🆘 If Something Goes Wrong

1. Check Render build logs
2. Check MongoDB Atlas connection logs
3. Verify all environment variables
4. Test API endpoints with curl
5. Review `COMPLETE_DEPLOYMENT_GUIDE.md` troubleshooting section

---

**Last Updated:** After completing deployment
**Status:** ⬜ Not Started | 🟡 In Progress | ✅ Complete

