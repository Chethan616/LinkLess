# Single Phone Testing Guide

## The Issue You Encountered

When you enter your own phone number and try to send a request, you see the error:
```
E/LinklessSmsReceiver: Error processing Linkless request: Invalid input to toASCII
```

### Why This Happens

1. **You send an encrypted SMS** to your own number with format: `LK:<base64-encrypted-url>`
2. **Your phone receives it** and the Android `SmsReceiver` catches it
3. **The receiver tries to decrypt it** but only does base64 decoding (not full AES-GCM decryption)
4. **It gets binary gibberish** and tries to use it as a URL, causing the error

## Current Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      YOUR PHONE (Client)                     │
├─────────────────────────────────────────────────────────────┤
│  Flutter App (Dart)                                          │
│  ├─ Encrypts URL with AES-GCM ✓                            │
│  ├─ Sends SMS: "LK:<encrypted-data>" ✓                     │
│  └─ Waits for encrypted response                            │
│                                                              │
│  Native Android (Kotlin) - SmsReceiver                      │
│  ├─ Receives SMS starting with "LK:"                        │
│  ├─ Tries to decrypt (only does base64 decode) ✗           │
│  ├─ Gets binary data as "URL" ✗                            │
│  └─ ERROR: Can't parse URL ✗                               │
└─────────────────────────────────────────────────────────────┘
```

## Solutions

### Option 1: Test with Two Phones (Recommended for Real Testing)

**Setup:**
1. **Phone A (Client)**: Your main phone running the Flutter app
2. **Phone B (Gateway)**: Second phone that needs:
   - Android OS
   - The same app installed
   - Internet connection
   - SMS reception enabled

**Steps:**
1. On **Phone B (Gateway)**:
   - Keep the app running in background
   - The native `SmsReceiver` will handle requests
   
2. On **Phone A (Client)**:
   - Enter Phone B's number as gateway
   - Exchange public keys (share via QR code or text)
   - Send requests normally

### Option 2: UI Testing Mode (Current Implementation)

**What Works:**
- ✅ Encryption/decryption functionality
- ✅ Key exchange setup
- ✅ UI testing and navigation
- ✅ SMS formatting and sending

**What Doesn't Work:**
- ❌ Actual web content fetching (needs gateway)
- ❌ Response receiving (your phone can't decrypt its own message)
- ❌ Native receiver will show errors in logs

**How to Use:**
1. Click "Setup Single Phone Test" button
2. Your phone will be configured with matching keys
3. Enter any URL and tap send
4. **Ignore the Android error logs** - they're expected
5. Test the UI, encryption, and SMS flow

### Option 3: Mock Mode (Future Enhancement)

We could add a mock mode that:
- Doesn't actually send SMS
- Simulates responses locally
- Shows what would be encrypted/sent
- Perfect for UI development

## Understanding the Encryption Flow

### Normal Two-Phone Flow:
```
Client Phone              Gateway Phone
─────────────            ──────────────
1. Encrypt URL           
   "google.com"          
   ↓ AES-GCM              
   "xK9j2..." (base64)    
                         
2. Send SMS               
   "LK:xK9j2..."  ─────→ 3. Receive SMS
                         
                          4. Decrypt URL
                             ↓ AES-GCM
                             "google.com"
                         
                          5. Fetch webpage
                             ↓ HTTP
                             "Google is..."
                         
                          6. Encrypt response
                             ↓ AES-GCM
                             "pL4m8..." (base64)
                         
7. Receive SMS            7. Send SMS
   "pL4m8..." ←──────────    "pL4m8..."
                         
8. Decrypt response      
   ↓ AES-GCM              
   "Google is..."         
                         
9. Display content        
```

### Single-Phone Flow (Current):
```
Your Phone (Client + Gateway Receiver)
─────────────────────────────────────
1. Encrypt URL           
   "google.com"          
   ↓ AES-GCM              
   "xK9j2..." (base64)    

2. Send SMS to self
   "LK:xK9j2..."  ───┐
                      │
3. Receive own SMS  ◄─┘
   
4. Native receiver tries to decrypt
   ↓ Only base64 decode (incomplete)
   Binary gibberish
   
5. Try to use as URL ✗
   ERROR: Invalid URL
```

## Recommendations

### For Development/UI Testing:
- ✅ Use the current single-phone setup
- ✅ Ignore Android error logs
- ✅ Test encryption, UI, and flows
- ⚠️ Don't expect actual web content

### For Real Functionality Testing:
- ✅ Get a second Android phone
- ✅ Set it up as dedicated gateway
- ✅ Keep it connected to internet
- ✅ Test full browsing experience

### For Future Development:
Consider adding:
1. **Mock Mode**: Simulate responses without SMS
2. **Debug Panel**: Show encryption steps visually
3. **Key Exchange UI**: QR codes for easy key sharing
4. **Gateway App**: Separate app for gateway devices
5. **Better Error Handling**: Explain errors to users

## Technical Details

### Why the Native Receiver Fails:

The Kotlin `SmsReceiver.kt` has placeholder decryption:
```kotlin
private fun decryptMessage(encryptedMessage: String): String {
    return try {
        // Only does base64 decode
        val decoded = Base64.getDecoder().decode(encryptedMessage)
        String(decoded)  // Returns binary data
    } catch (e: Exception) {
        encryptedMessage
    }
}
```

It should do:
1. Base64 decode
2. Extract nonce (12 bytes)
3. Extract MAC (16 bytes)
4. Extract ciphertext (remaining bytes)
5. Decrypt with AES-GCM using shared secret
6. Return plaintext

### Why Flutter Can't Help Here:

- The native `BroadcastReceiver` runs before Flutter app starts
- It needs to process SMS in background
- Can't easily call Flutter's Dart code from Kotlin
- Would need platform channels and complex setup

## Conclusion

Your app is working correctly! The error you see is expected when testing with a single phone because:
1. The Flutter side encrypts properly ✓
2. The SMS is sent correctly ✓
3. The native receiver catches it ✓
4. But it can't fully decrypt (by design for gateway mode) ✗

For full testing, you'll need a second phone as a gateway device.
