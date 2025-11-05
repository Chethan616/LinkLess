# How Linkless Browser Works

## 🎯 Overview

Linkless Browser is a revolutionary app that allows you to browse the web **without an internet connection** using SMS messages. It's a two-phone system where one phone (Client) has no internet but can still access web content through another phone (Gateway) that has internet.

---

## 📱 Two-Phone System

### **Phone 1: Client Device (You)**
- **No internet connection required**
- Runs the Linkless Browser app
- Sends URL requests via SMS
- Receives encrypted web content

### **Phone 2: Gateway Device (Helper)**
- **Needs internet connection**
- Also runs the Linkless Browser app
- Receives URL requests via SMS
- Fetches web content
- Sends encrypted content back via SMS

---

## 🔄 Complete Workflow

### **Step 1: Initial Setup**

1. **Install the app on both phones**
   - Phone 1 (Client - no internet)
   - Phone 2 (Gateway - with internet)

2. **Exchange Public Keys** (First time only)
   - Both phones generate cryptographic key pairs
   - Exchange public keys via SMS for secure communication
   - Uses X25519 elliptic curve key exchange

3. **Configure Gateway Number**
   - Client device saves Gateway phone number
   - This is where all requests will be sent

---

### **Step 2: Browsing Process**

#### **On Client Device (No Internet):**

1. **User opens Linkless Browser**
   - Opens the Browser tab
   - Sees the URL input field

2. **User enters a URL**
   - Example: `wikipedia.org` or `bbc.com/news`
   - Taps the send button

3. **Request Encryption**
   - App encrypts the URL using AES-GCM 256-bit encryption
   - Adds the "LK:" prefix to identify Linkless messages
   - Sends encrypted SMS to Gateway device

4. **Wait for Response**
   - Shows loading indicator
   - "Fetching content..." message appears

5. **Receive and Display**
   - Receives encrypted response via SMS
   - Decrypts content using shared secret
   - Displays webpage text in clean format
   - Saves to browsing history

---

#### **On Gateway Device (With Internet):**

1. **Background SMS Receiver**
   - Always listening for SMS with "LK:" prefix
   - Automatically processes Linkless requests

2. **Decrypt Request**
   - Receives encrypted SMS from Client
   - Decrypts URL using AES-GCM
   - Validates message authenticity

3. **Fetch Web Content**
   - Uses Jsoup library to scrape webpage
   - Downloads HTML content
   - Extracts main text (removes ads, scripts, styles)
   - Limits content to ~1200 characters (SMS constraint)

4. **Encrypt and Send Back**
   - Encrypts webpage content with AES-GCM
   - Sends back via SMS with "LK:" prefix
   - Client receives and decrypts

---

## 🔐 Security Architecture

### **Encryption Stack:**

1. **X25519 Key Exchange**
   - Elliptic curve Diffie-Hellman (ECDH)
   - Generates shared secret between devices
   - No keys transmitted insecurely
   - Perfect forward secrecy

2. **AES-GCM 256-bit Encryption**
   - Symmetric encryption for all messages
   - 256-bit keys (extremely secure)
   - 12-byte random nonce (prevents replay attacks)
   - 16-byte MAC tag (ensures authenticity)

3. **Base64 Encoding**
   - Encrypted binary data → text format
   - Safe for SMS transmission
   - Decode on receiving end

### **Message Format:**
```
LK:<Base64(Encrypted(URL or Content))>
```

Example encrypted message:
```
LK:SGVsbG8gV29ybGQhIFRoaXMgaXMgZW5jcnlwdGVkIQ==
```

---

## 🏗️ Technical Architecture

### **Frontend (Flutter/Dart)**

1. **lib/ui/screens/**
   - `home_screen.dart` - Main app with tabs
   - `browser_tab.dart` - URL input and content display
   - `history_tab.dart` - Browse past requests

2. **lib/ui/widgets/**
   - `input_field.dart` - Safari-style URL input
   - `message_bubble.dart` - Content display cards

3. **lib/services/**
   - `crypto_service.dart` - AES-GCM + X25519 encryption
   - `sms_service.dart` - SMS send/receive
   - `platform_bridge.dart` - Dart ↔ Kotlin bridge

4. **lib/core/**
   - `colors.dart` - Dark (#B3FF9D) / Light (#07BDFF) themes
   - `theme.dart` - Material + Cupertino styling

---

### **Backend (Kotlin/Android)**

1. **SmsReceiver.kt**
   - BroadcastReceiver for incoming SMS
   - Filters messages with "LK:" prefix
   - Decrypts request
   - Triggers web fetch
   - Encrypts and sends response

2. **FetchWebHandler.kt**
   - Uses Jsoup for web scraping
   - Connects to URL with 10-second timeout
   - Extracts text content
   - Limits to 1200 characters
   - Returns to Flutter via MethodChannel

3. **MainActivity.kt**
   - Sets up MethodChannel "linkless_gateway"
   - Bridges Dart and Kotlin
   - Handles Flutter-to-native calls

---

## 📊 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT DEVICE (No Internet)              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. User enters URL: "wikipedia.org"                       │
│      ↓                                                      │
│  2. Encrypt with AES-GCM (256-bit)                         │
│      ↓                                                      │
│  3. Format: "LK:SGVsb...encrypted...=="                    │
│      ↓                                                      │
│  4. Send SMS to Gateway (+1234567890)                      │
│      ↓                                                      │
│  5. Show loading indicator...                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓ SMS
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   GATEWAY DEVICE (With Internet)            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  6. Receive SMS "LK:SGVsb...encrypted...=="               │
│      ↓                                                      │
│  7. Decrypt with AES-GCM                                   │
│      → URL: "wikipedia.org"                                │
│      ↓                                                      │
│  8. Fetch webpage with Jsoup                               │
│      → Connect to https://wikipedia.org                    │
│      → Download HTML                                       │
│      → Extract text (max 1200 chars)                       │
│      ↓                                                      │
│  9. Encrypt content with AES-GCM                           │
│      ↓                                                      │
│ 10. Send SMS back "LK:Q29udGVu...encrypted...=="          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓ SMS
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT DEVICE (No Internet)              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 11. Receive response SMS                                    │
│      ↓                                                      │
│ 12. Decrypt content                                         │
│      ↓                                                      │
│ 13. Display webpage text                                    │
│      ↓                                                      │
│ 14. Save to browsing history                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 💡 Use Cases

### **1. Emergency Situations**
- Natural disasters (no internet infrastructure)
- Remote areas with no data coverage
- Access critical information (news, emergency contacts)

### **2. Privacy-Conscious Users**
- No ISP tracking
- No browser history on internet-connected device
- Encrypted end-to-end communication

### **3. Data-Free Browsing**
- No internet plan on primary phone
- Borrow friend's phone as Gateway
- Still access web content

### **4. Censorship Circumvention**
- Government-blocked internet on device
- Use trusted Gateway in different location
- SMS-based content delivery

---

## ⚠️ Limitations

1. **Content Size**
   - Limited to ~1200 characters per request
   - Text-only (no images, videos, CSS)
   - Multiple SMS for longer content

2. **Speed**
   - SMS delivery time (5-30 seconds typically)
   - Not suitable for real-time browsing
   - Better for static content

3. **Cost**
   - Uses SMS credits (not free)
   - May incur carrier charges
   - International SMS can be expensive

4. **Content Quality**
   - Text extraction only
   - No formatting or styles
   - May lose context without images

---

## 🎨 UI Design Highlights

### **Safari-Inspired Interface**

1. **Floating Input Cards**
   - Rounded 14px corners
   - Elevated shadows
   - Smooth animations (250ms)

2. **Modern Typography**
   - Font weight: 600-700 for titles
   - Letter spacing: -0.5 to 0.3
   - Height: 1.5-1.6 for readability

3. **Gradient Accents**
   - Loading indicators with gradients
   - Empty state icons with subtle gradients
   - Send button with primary color gradient

4. **Dark Mode (AMOLED)**
   - Pure black (#000000) background
   - Neon green (#B3FF9D) accents
   - Battery-saving design

5. **Light Mode**
   - Clean white (#FFFFFF) background
   - Cyan blue (#07BDFF) accents
   - High contrast for readability

---

## 🚀 Getting Started

### **Requirements:**
- 2 Android phones
- SMS capabilities on both
- Internet on Gateway phone
- Flutter 3.9.2+ for development

### **Setup:**
```bash
# Clone the repository
git clone <repo_url>

# Install dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Install on both devices
adb install build/app/outputs/flutter-apk/app-release.apk
```

### **First Use:**
1. Open app on both phones
2. Go to Browser tab
3. Set Gateway number on Client
4. Exchange public keys (automatic via SMS)
5. Start browsing!

---

## 🔧 Troubleshooting

### **"SMS permissions not granted"**
- Go to Android Settings → Apps → Linkless Browser → Permissions
- Enable SMS permissions

### **"Crypto service not ready"**
- Ensure both devices have exchanged public keys
- Check if Gateway number is set correctly

### **"Failed to send SMS request"**
- Check cellular signal
- Verify Gateway phone number format (+1234567890)
- Ensure SMS balance available

### **No response from Gateway**
- Check Gateway phone has internet
- Verify Gateway app is installed and running
- Check SMS is received (look for "LK:" prefix)

---

## 📝 Summary

**Linkless Browser = SMS + Encryption + Web Scraping**

1. **Client** → Encrypt URL → SMS to Gateway
2. **Gateway** → Decrypt → Fetch webpage → Encrypt content → SMS back
3. **Client** → Decrypt → Display → Save to history

All communication is **end-to-end encrypted** with military-grade AES-GCM 256-bit encryption, ensuring your browsing remains private and secure even over SMS!

---

## 🎯 Key Innovations

- ✅ **First SMS-based encrypted web browser**
- ✅ **Zero internet required on client**
- ✅ **Military-grade encryption (AES-GCM 256-bit)**
- ✅ **Safari-inspired modern UI**
- ✅ **AMOLED dark mode for battery saving**
- ✅ **Cross-platform (Flutter)**
- ✅ **Open source and privacy-focused**

---

*Built with ❤️ using Flutter, Kotlin, AES-GCM, X25519, and Jsoup*
