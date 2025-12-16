# Enable Developer Mode on iPhone - Quick Guide

## Step-by-Step Instructions

### Step 1: Enable Developer Mode on iPhone

1. **On your iPhone**, go to:
   - **Settings** → **Privacy & Security**

2. **Scroll down** to find **"Developer Mode"**

3. **Toggle Developer Mode ON**

4. **Your iPhone will prompt you to restart** - Tap **"Restart"**

5. **After restart**, your iPhone will ask you to confirm:
   - A popup will appear asking "Turn on Developer Mode?"
   - Tap **"Turn On"**
   - Enter your **passcode** to confirm

### Step 2: Trust the Computer (if needed)

1. **Unlock your iPhone**

2. **If you see a popup** asking "Trust This Computer?" → Tap **"Trust"**

3. **Enter your iPhone passcode** when prompted

### Step 3: Trust Developer Certificate in Xcode

1. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Connect your iPhone** (if not already connected)

3. **In Xcode**, you should see your device in the device list

4. **Select your device** from the device dropdown

5. **Xcode may prompt you** to trust the developer certificate on your device

6. **On your iPhone**, go to:
   - **Settings** → **General** → **VPN & Device Management** (or **Device Management**)
   - Tap on your **Developer App** certificate
   - Tap **"Trust"** and confirm

### Step 4: Run the App Again

After enabling Developer Mode and restarting:

```bash
flutter run -d "00008030-0018141C3442802E"
```

Or simply:
```bash
flutter run
```

## Troubleshooting

### Developer Mode option not showing?

- Make sure your iPhone is **unlocked**
- Try **disconnecting and reconnecting** the USB cable
- Make sure you're on **iOS 16 or later**
- Try opening Xcode first, then connect the device

### Still not working?

1. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **In Xcode**:
   - Select **Runner** project
   - Go to **Signing & Capabilities**
   - Check **"Automatically manage signing"**
   - Select your **Team** (Apple ID)

3. **Try running from Xcode**:
   - Select your device from the device dropdown
   - Click the **Play** button (▶️)

## Quick Checklist

- [ ] Developer Mode enabled in Settings → Privacy & Security
- [ ] iPhone restarted after enabling Developer Mode
- [ ] Confirmed "Turn on Developer Mode?" popup
- [ ] Trusted the computer (if prompted)
- [ ] Xcode signing configured
- [ ] Developer certificate trusted on device

---

**Note:** Developer Mode is required for iOS 16+ devices. This is a security feature by Apple.
