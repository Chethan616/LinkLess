# 📱 Linkless Two-Phone Deployment Instructions

## ⚠️ CRITICAL: Two Different App Configurations Needed

Your Linkless SMS browsing system requires **TWO PHONES** with **DIFFERENT** app configurations:

---

## 📱 Phone 1: CLIENT Phone (Your Current Phone - CPH2487)

### Configuration:
- **Native Receiver**: DISABLED ❌ (Already done!)
- **Purpose**: Sends URLs, receives webpage content
- **AndroidManifest.xml Status**: Native receiver is commented out ✅

### Current State: ✅ READY TO USE
The client phone is already properly configured.

---

## 📱 Phone 2: GATEWAY Phone (Other Phone)

### Configuration:
- **Native Receiver**: ENABLED ✅ (Needs to be uncommented!)
- **Purpose**: Receives URLs, fetches webpages, sends content back
- **AndroidManifest.xml Status**: Native receiver MUST be active

### ⚠️ ACTION REQUIRED:

**Before installing on gateway phone, you MUST:**

1. **Uncomment the receiver in AndroidManifest.xml:**

```xml
<!-- SMS Receiver for Gateway mode -->
<!-- ENABLED FOR GATEWAY MODE -->
<receiver
    android:name=".SmsReceiver"
    android:exported="true"
    android:permission="android.permission.BROADCAST_SMS">
    <intent-filter android:priority="999">
        <action android:name="android.provider.Telephony.SMS_RECEIVED"/>
    </intent-filter>
</receiver>
```

2. **Build and install GATEWAY version:**
```bash
flutter build apk
# Then install the APK on the gateway phone
```

---

## 🔄 Why Two Configurations?

### CLIENT Phone:
- Flutter's `Telephony` plugin receives ALL SMS
- Native receiver is disabled to prevent interference
- Decodes Base64 responses and displays content

### GATEWAY Phone:
- Native `SmsReceiver.kt` intercepts "LK:" messages
- Fetches webpages using Jsoup
- Sends Base64 encoded responses back

### ❌ What Happens if Both Have Same Config?
- **Both disabled**: Gateway won't fetch webpages (native receiver needed)
- **Both enabled**: Client won't display content (native intercepts replies)

---

## 📋 Step-by-Step Setup

### On CLIENT Phone (CPH2487):
1. ✅ Already done! Keep current installation
2. Set gateway number to: `+919966029761`
3. Test by entering: `google.com`

### On GATEWAY Phone (+919966029761):
1. Edit `android/app/src/main/AndroidManifest.xml`
2. Uncomment lines 39-46 (the receiver block)
3. Change priority from `0` to `999`
4. Run: `flutter build apk`
5. Install the generated APK
6. Grant SMS permissions
7. Keep the app running in background

---

## 🧪 Testing Checklist

### After Setup:
- [ ] Gateway phone has receiver enabled (priority 999)
- [ ] Client phone has receiver disabled (commented out)
- [ ] Both phones have SMS permissions granted
- [ ] Gateway number set in client: `+919966029761`

### Send Test Request:
1. On client, enter: `google.com`
2. Client logs: `I/flutter: === SMS SEND DEBUG (TEST MODE) ===`
3. Gateway logs: `D/LinklessSmsReceiver: Received SMS from +91...`
4. Gateway logs: `D/LinklessSmsReceiver: Fetching content from: https://google.com`
5. Client receives Base64 SMS
6. Client logs: `I/flutter: TEST MODE: Decoding Base64 response`
7. Content appears on screen! ✅

---

## 🐛 Troubleshooting

### Problem: "Fetching content..." never stops
**Cause**: Gateway phone not running or receiver disabled
**Fix**: 
1. Check gateway phone has receiver uncommented
2. Rebuild and reinstall on gateway
3. Check gateway has internet connection

### Problem: Client receives SMS but nothing displays
**Cause**: Client's native receiver still enabled
**Fix**:
1. Verify receiver is commented out in client's manifest
2. Rebuild client app with `flutter run`

### Problem: Gateway doesn't respond
**Cause**: Gateway doesn't have internet or Jsoup failed
**Fix**:
1. Check gateway logs for errors
2. Try simpler URL: `example.com`
3. Verify gateway has mobile data/WiFi

---

## 📱 Current Status

### CLIENT Phone (CPH2487): ✅ READY
- AndroidManifest.xml: Receiver disabled
- Last build: Successful
- Test mode: ENABLED
- Waiting for: Gateway phone setup

### GATEWAY Phone (+919966029761): ⚠️ NEEDS UPDATE
- Current state: OLD version (receiver enabled but priority 0)
- Required action: Uncomment receiver with priority 999
- Required action: Rebuild and install

---

## 🚀 Next Steps

1. **Uncomment the receiver in AndroidManifest.xml**
2. **Change priority to 999**
3. **Run `flutter run` on this terminal to update CLIENT**
4. **Build APK for GATEWAY and install on other phone**
5. **Test with `google.com`**

---

## 💡 Future: Single APK with Runtime Mode Selection

Consider implementing:
- Runtime detection of phone role (client vs gateway)
- Dynamic receiver registration/unregistration
- Settings toggle: "Use as Gateway" / "Use as Client"
- Automatic mode based on phone number configuration

---

Generated: 2025-11-06
Version: Test Mode v1.0
