# 🔄 Auto-Ping Setup (Keep Render Server Alive)

## Overview

The server now includes an auto-ping feature that pings itself every 14 minutes to prevent Render's free tier from spinning down.

## How It Works

- **Interval:** Every 14 minutes (840,000 milliseconds)
- **Endpoint:** `/health`
- **Purpose:** Keep Render server alive (free tier spins down after 15 min inactivity)

## Configuration

### Option 1: Environment Variable (Recommended)

Add to your `.env` file or Render environment variables:

```env
SERVER_URL=https://scanface-tztq.onrender.com
```

Or:

```env
RENDER_URL=https://scanface-tztq.onrender.com
```

### Option 2: Auto-Detection

If `NODE_ENV=production` and no URL is set, it will try to use:
- `RENDER_EXTERNAL_URL` (set by Render automatically)
- Or default: `https://scanface-tztq.onrender.com`

## For Render Deployment

Add this environment variable in Render dashboard:

```
RENDER_URL=https://scanface-tztq.onrender.com
```

Or:

```
SERVER_URL=https://scanface-tztq.onrender.com
```

## How to Verify

1. Check server logs - you should see:
   ```
   🔄 Auto-ping enabled: Will ping https://scanface-tztq.onrender.com/health every 14 minutes
   ✅ Auto-ping successful: https://scanface-tztq.onrender.com/health - 3:45:23 PM
   ```

2. The ping happens:
   - Immediately when server starts
   - Then every 14 minutes automatically

## Manual Test

You can test the ping manually:

```bash
curl https://scanface-tztq.onrender.com/health
```

Should return: `{"status":"ok","database":"connected",...}`

## Notes

- Only runs in production or when SERVER_URL/RENDER_URL is set
- Won't run in local development (unless URL is explicitly set)
- Uses HTTPS for Render URLs
- 10-second timeout per ping
- Logs success/failure to console

