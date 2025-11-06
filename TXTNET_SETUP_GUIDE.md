# 📱 LinkLess - TxtNet Style SMS Browser Setup Guide

## 🎯 How It Works (Like TxtNet)

Your app is a **pure SMS-based web browser** - no Twilio, no internet on client phone needed!

```
┌──────────────┐         SMS          ┌──────────────┐
│              │  LK:https://...      │              │
│ CLIENT PHONE │ ─────────────────▶   │ GATEWAY PHONE│
│  (No WiFi)   │                      │  (Has WiFi)  │
│              │  ◀─────────────────  │              │
│   Displays   │   Base64 content     │ Fetches Web  │
└──────────────┘                      └──────────────┘
```

## 🚀 Quick Setup (2 Phones Required)

### Phone 1: Gateway (Must Have Internet)
1. Install the LinkLess app
2. Open app → Go to **Settings** tab
3. Tap **"Gateway Mode"**
4. Confirm and restart app
5. **Keep app running** in the background
6. Gateway is now active! ✅

### Phone 2: Client (Your Phone - No Internet Needed)
1. Install the LinkLess app  
2. Open app → Go to **Settings** tab
3. Stay in **"Client Mode"** (default)
4. Enter Gateway phone number (e.g., `+919392199283`)
5. Save and go to **Browser** tab
6. Enter any URL (e.g., `google.com`)
7. Tap **Browse** → SMS sent! ✅
8. Wait 5-15 seconds
9. Content appears! 🎉

## 📋 What Happens Under the Hood

### When You Browse (Client Side):
1. You enter `google.com`
2. App sends SMS: `LK:https://google.com` to gateway
3. Native Android receiver catches incoming response
4. Flutter decodes Base64 content
5. UI displays webpage text

### On Gateway Phone:
1. SMS received: `LK:https://google.com`
2. Native `SmsReceiver.kt` intercepts it
3. Jsoup fetches webpage (max 1200 chars)
4. Encodes as Base64
5. Sends SMS back to client
6. **All automatic!**

## ✅ Current Status (November 6, 2025)

### ✅ Working Features:
- SMS sending from client
- Native BroadcastReceiver enabled (priority 0)
- Gateway webpage fetching (Jsoup)
- Base64 encoding/decoding
- Test mode (unencrypted URLs)
- Dual-mode support (Client/Gateway)
- Settings UI with mode switcher
- 60-second request timeout

### ⚠️ Known Limitations:
- Max content: 1200 characters
- SMS costs apply (carrier charges)
- Response time: 5-15 seconds
- No images/CSS (text only)
- Gateway must stay active

## 🔧 Troubleshooting

### Problem: "Request timed out"
**Solution:**
1. Check gateway phone has internet
2. Verify gateway app is running
3. Check SMS was sent (check phone's Messages app)
4. Gateway number correct in Settings?

### Problem: "No response received"
**Solution:**
1. Gateway phone: Settings → Apps → LinkLess → Permissions → SMS → Allow
2. Client phone: Check SMS permissions
3. Verify both phones can send/receive SMS normally
4. Test with manual SMS first

### Problem: SMS received but no content
**Check gateway logs:**
```bash
adb logcat | grep LinklessSmsReceiver
```
Look for:
- `Received SMS from: +91...`
- `Fetching URL: https://...`
- `Fetched XXX characters`

## 📊 Technical Architecture

### Client Phone (Flutter + Native):
```
┌─────────────────────────────────────┐
│ Flutter UI (browser_tab.dart)      │
│  └─> SmsService.sendRequest()      │
│       └─> Telephony.sendSms()      │
└─────────────────────────────────────┘
           ▼ SMS: LK:URL
┌─────────────────────────────────────┐
│ Response SMS arrives                │
│  └─> SmsReceiver.kt (priority 0)   │
│       └─> Forward to Flutter        │
│            └─> Telephony listener   │
│                 └─> Decode Base64   │
│                      └─> Display UI │
└─────────────────────────────────────┘
```

### Gateway Phone (Native + Jsoup):
```
┌─────────────────────────────────────┐
│ SMS arrives: LK:URL                 │
│  └─> SmsReceiver.kt.onReceive()    │
│       └─> Check "LK:" prefix        │
│            └─> Extract URL           │
│                 └─> Jsoup.connect() │
│                      └─> Fetch HTML │
│                           └─> .text()│
│                                └─> Limit 1200 chars│
│                                     └─> Base64.encode()│
│                                          └─> sendSms()│
└─────────────────────────────────────┘
```

## 🔐 Test Mode vs Production

### Current: TEST MODE ✅
- URLs sent **unencrypted** in SMS
- Responses **Base64 encoded** (not encrypted)
- Easy debugging, visible in SMS logs
- **Recommended for testing**

### Future: Production Mode
- URLs **AES-GCM encrypted**
- Responses **AES-GCM encrypted**
- Keys exchanged via Settings
- **Not implemented yet**

## 📝 Example Test Scenarios

### Test 1: Simple Website
```
Client: Enter "example.com"
Gateway: Fetches http://example.com
Client: Sees "Example Domain This domain is for..."
```

### Test 2: News Site
```
Client: Enter "bbc.com"
Gateway: Fetches http://bbc.com
Client: Sees first 1200 chars of BBC homepage
```

### Test 3: Search
```
Client: Enter "google.com"
Gateway: Fetches http://google.com
Client: Sees Google search page text
```

## 🎨 UI Features

### Browser Tab:
- URL input with auto https://
- Liquid glass design
- Loading spinner
- Timeout indicator
- Scrollable content view

### History Tab:
- Saves all browsed URLs
- View past requests
- Clear history option

### Settings Tab:
- Mode switcher (Client/Gateway)
- Gateway number editor
- About section
- App version info

## 💾 File Structure

```
lib/
├── services/
│   ├── sms_service.dart         # SMS handling
│   ├── crypto_service.dart      # Encryption (future)
│   └── app_mode_service.dart    # Mode management
├── ui/
│   ├── screens/
│   │   ├── browser_tab.dart     # Main UI
│   │   ├── history_tab.dart     # History
│   │   └── settings_tab.dart    # Settings
│   └── widgets/
│       └── liquid_glass_*.dart  # UI components
└── main.dart

android/app/src/main/kotlin/com/example/linkless/
├── MainActivity.kt
├── SmsReceiver.kt               # SMS gateway logic ⭐
└── FetchWebHandler.kt           # Jsoup web fetching
```

## 🚦 Status Indicators

### Green ✅: Ready
- Settings saved
- Permissions granted
- SMS service initialized

### Yellow ⚠️: Waiting
- Fetching content...
- Sending request...

### Red ❌: Error
- Permission denied
- Network error
- Timeout

## 📞 SMS Message Format

### Client → Gateway:
```
LK:https://example.com
```

### Gateway → Client:
```
VGhpcyBpcyB0aGUgd2VicGFnZSBjb250ZW50IGVuY29kZWQgaW4gQmFzZTY0...
(Base64 encoded webpage text)
```

## 🔋 Battery & Data Usage

### Gateway Phone:
- **SMS**: ~0.5 KB per request
- **Data**: Varies by webpage (typically 10-500 KB)
- **Battery**: Minimal (receiver waits passively)

### Client Phone:
- **SMS**: ~0.5 KB per request + response
- **Data**: Zero! ✨
- **Battery**: Very low

## 🌟 Best Practices

1. **Gateway Setup**: Use a phone with unlimited data
2. **Client Usage**: Turn off mobile data completely
3. **Testing**: Start with small sites (example.com)
4. **Debugging**: Keep both phones unlocked during tests
5. **Production**: Consider SMS costs (usually 5-10¢ per message)

## 🆘 Support & Debugging

### Enable Detailed Logs:
```bash
# Gateway phone:
adb logcat | grep -E "LinklessSmsReceiver|Jsoup"

# Client phone:
adb logcat | grep -E "flutter.*SMS|flutter.*LK:"
```

### Check SMS Permissions:
```bash
adb shell pm grant com.example.linkless android.permission.SEND_SMS
adb shell pm grant com.example.linkless android.permission.RECEIVE_SMS
adb shell pm grant com.example.linkless android.permission.READ_SMS
```

### Test Native Receiver:
Send manual SMS from any phone:
```
LK:https://example.com
```
Check gateway logs for processing.

---

## 🎉 Success Checklist

Before reporting issues, verify:
- [ ] Both phones have SMS permissions
- [ ] Gateway phone has internet connection
- [ ] Gateway app is running (not force-stopped)
- [ ] Client has correct gateway number in Settings
- [ ] SMS works normally between the two phones
- [ ] Test with simple URL first (example.com)

---

**Built with ❤️ on November 6, 2025**  
**Version**: 1.0.0 (TxtNet-style)  
**Status**: Ready for testing ✅
