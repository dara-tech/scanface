# MongoDB Setup Guide

## ✅ Issue Fixed
The MongoDB connection error has been fixed by removing deprecated options (`useNewUrlParser`, `useUnifiedTopology`).

## 🗄️ MongoDB Installation Options

### Option 1: Docker (Recommended - Easiest)

```bash
# Run MongoDB in Docker
docker run -d \
  --name attendance-mongodb \
  -p 27017:27017 \
  -v mongodb_data:/data/db \
  mongo:6.0

# Check if it's running
docker ps | grep mongo

# View logs
docker logs attendance-mongodb
```

### Option 2: Homebrew (macOS)

```bash
# Install MongoDB
brew tap mongodb/brew
brew install mongodb-community

# Start MongoDB
brew services start mongodb-community

# Or run manually
mongod --config /opt/homebrew/etc/mongod.conf
```

### Option 3: MongoDB Atlas (Cloud - Free Tier)

1. Go to https://www.mongodb.com/cloud/atlas
2. Create a free account
3. Create a free cluster
4. Get connection string
5. Update `.env`:
   ```env
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/attendance_app
   ```

## 🔧 Verify MongoDB Connection

### Test Connection
```bash
# Using mongosh (MongoDB Shell)
mongosh

# Or test connection string
mongosh "mongodb://localhost:27017/attendance_app"
```

### Check Server Status
```bash
# Health check endpoint
curl http://localhost:3000/health

# Should show:
# {"status":"ok","database":"connected"}
```

## 🐛 Troubleshooting

### MongoDB Not Starting
```bash
# Check if port 27017 is in use
lsof -i :27017

# Kill process if needed
kill -9 <PID>
```

### Connection Refused
- Make sure MongoDB is running
- Check firewall settings
- Verify connection string in `.env`

### Docker Container Issues
```bash
# Restart container
docker restart attendance-mongodb

# Remove and recreate
docker rm -f attendance-mongodb
docker run -d --name attendance-mongodb -p 27017:27017 mongo:6.0
```

## ✅ Quick Start (Docker)

```bash
# 1. Start MongoDB
docker run -d --name attendance-mongodb -p 27017:27017 mongo:6.0

# 2. Wait a few seconds for MongoDB to start

# 3. Check server health
curl http://localhost:3000/health

# Should show: "database":"connected"
```

## 📝 Next Steps

Once MongoDB is connected:
1. ✅ Server will show: `✅ MongoDB Connected`
2. ✅ Health check will show: `"database":"connected"`
3. ⏭️ Ready to create API routes
4. ⏭️ Ready to test Socket.io

---

**Current Status**: Server running ✅ | MongoDB: Needs to be started

