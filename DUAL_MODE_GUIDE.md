# 🎉 Linkless Dual-Mode System - USER GUIDE

## ✨ What's New?

Your Linkless app now has **TWO MODES** in a **SINGLE APK**! No more manual code changes needed!

---

## 📱 Two Modes, One App

### 📱 **Client Mode** (Default)
- **Purpose**: Browse the web via SMS
- **What it does**:
  - You enter URLs
  - Sends requests to gateway via SMS
  - Receives and displays webpage content
- **Requirements**:
  - Need a gateway phone number
  - Need SMS permissions

### 🌐 **Gateway Mode**
- **Purpose**: Fetch webpages for other phones
- **What it does**:
  - Receives URL requests via SMS
  - Fetches webpages using internet
  - Sends content back via SMS
- **Requirements**:
  - Internet connection
  - SMS permissions
  - Keep app running in background

---

## 🚀 How to Switch Modes

### Step 1: Open Settings Tab
1. Launch the Linkless app
2. Tap the **Settings** tab (⚙️) at the bottom
3. You'll see "App Mode" section at the top

### Step 2: Choose Your Mode
**Option A: Client Mode** (for browsing)
- Tap on "📱 Client Mode"
- Confirm the switch
- Set your gateway phone number

**Option B: Gateway Mode** (for serving)
- Tap on "🌐 Gateway Mode"
- Confirm the switch
- App becomes a gateway server

### Step 3: Restart the App
- Close the app completely
- Reopen it
- New mode is active! ✅

---

## 🔄 Typical Setup (Two Phones)

### Phone 1: Your Main Phone (Client)
1. Keep in **Client Mode** (default)
2. Go to Settings → Gateway Configuration
3. Enter Phone 2's number (e.g., `+919966029761`)
4. Save and start browsing!

### Phone 2: Gateway Server
1. Switch to **Gateway Mode** in Settings
2. Confirm and restart app
3. Make sure it has internet connection
4. Keep app running in background
5. Done! It will serve requests automatically

---

## 💡 Features in Settings

### 🎯 App Mode Selector
- **Visual indicators**: Green checkmark shows active mode
- **Tap to switch**: Just tap the mode you want
- **Confirmation dialog**: Prevents accidental switches

### 📞 Gateway Configuration (Client Mode Only)
- **Set gateway number**: Tap "Set Gateway Number"
- **Edit existing**: Tap the pencil icon
- **Auto-saves**: Number syncs with app instantly

### ✅ Gateway Status (Gateway Mode Only)
- **Real-time status**: Shows if gateway is active
- **Requirements checklist**: Reminds you what's needed
- **Quick tips**: Helpful hints for best performance

### ℹ️ About Section
- **Version info**: Current app version
- **Description**: What Linkless does

---

## 🎨 User Experience Highlights

###Smart Detection
When you open the Browser tab:
- **Client Mode**: Shows URL input and content display
- **Gateway Mode**: Shows "Gateway Mode Active" message
- **No confusion**: Clear visual feedback

### 💾 Persistent Settings
- Mode choice is **saved locally**
- Gateway number **remembered across sessions**
- **No cloud sync needed** - all stored on device

### 🔄 Easy Mode Switching
- **One-tap toggle**: Switch modes anytime
- **Clear warnings**: Restart required notification
- **Guided process**: Step-by-step confirmations

---

## 📋 Quick Start Guide

### For First-Time Users:

**If you're the BROWSER user:**
1. Open app (defaults to Client Mode)
2. Go to Settings tab
3. Tap "Set Gateway Number"
4. Enter your friend's gateway phone number
5. Go to Browser tab
6. Enter a URL and browse!

**If you're the GATEWAY provider:**
1. Open app
2. Go to Settings tab
3. Tap "🌐 Gateway Mode"
4. Confirm and restart app
5. Keep app open and connected to internet
6. Tell your friends your phone number!

---

## 🐛 Troubleshooting

### "Crypto service not ready" error
→ Make sure you're in **Client Mode** and have set a gateway number

### Gateway not responding
→ Check that:
- Gateway phone is in **Gateway Mode**
- Gateway has internet connection
- Gateway app is running
- SMS permissions are granted on both phones

### Can't switch modes
→ Make sure you:
- Confirmed the switch in the dialog
- **Restarted the app** (close completely and reopen)

### Content not displaying
→ Verify:
- You're in **Client Mode**
- Gateway number is set correctly
- Gateway phone is online and in Gateway Mode

---

## 🎯 Best Practices

### For Client Users:
✅ Set gateway number before browsing
✅ Keep TEST MODE enabled for now (until encryption is fully implemented)
✅ Check Settings if you encounter issues

### For Gateway Users:
✅ Keep app running in background
✅ Maintain stable internet connection
✅ Don't switch modes while serving requests
✅ Monitor battery usage (gateway mode is active)

---

## 🔒 Security Note

**Current Status: TEST MODE**
- URLs are currently sent **unencrypted**
- Content is Base64 encoded (not encrypted)
- **For testing purposes only**

**Future: Production Mode**
- Full AES-GCM 256-bit encryption
- X25519 key exchange
- End-to-end security

---

## 📱 Architecture

```
┌─────────────────┐         SMS          ┌─────────────────┐
│  CLIENT PHONE   │ ◄─────────────────► │  GATEWAY PHONE  │
│  (Your Phone)   │                      │  (Friend's)     │
│                 │  "LK:google.com"     │                 │
│  Client Mode    │ ────────────────────►│  Gateway Mode   │
│                 │                      │      ↓          │
│                 │  Base64 Content      │  Fetch Web      │
│  Display ✨     │ ◄────────────────────│  (Jsoup)        │
└─────────────────┘                      └─────────────────┘
```

---

## 🎉 Advantages of Dual-Mode

### Before (Manual):
❌ Two different builds needed
❌ Edit AndroidManifest.xml manually
❌ Rebuild and install separately
❌ Confusing for users
❌ Easy to make mistakes

### After (Dual-Mode):
✅ **Single APK** for both modes
✅ **One-tap** mode switching
✅ **No code editing** required
✅ **User-friendly** Settings UI
✅ **Save and remember** preferences

---

## 📞 Support

Having issues? Check:
1. **Settings Tab** - Verify your mode and configuration
2. **Permissions** - SMS permissions granted on both phones
3. **Internet** - Gateway needs active connection
4. **Phone Numbers** - Correct gateway number saved

---

## 🚀 Next Steps

1. **Install the app** on both phones
2. **Set up modes** (one Client, one Gateway)
3. **Configure gateway number** on client
4. **Start browsing** the SMS web!

---

**Version**: 1.0.0 (Dual-Mode System)  
**Date**: November 6, 2025  
**Status**: Test Mode Active ⚠️

**Enjoy browsing without internet!** 🌐📱
