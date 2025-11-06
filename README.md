# 🔐 Linkless Browser v1.0

**Encrypted SMS Web Browsing for Everyone**

Browse the web without internet using end-to-end encrypted SMS messages. Linkless Browser enables secure, privacy-focused web access via existing mobile infrastructure.

---

## ✨ Features

### 🔒 Security & Privacy
- **End-to-End Encryption**: AES-GCM 256-bit encryption
- **Secure Key Exchange**: X25519 elliptic curve
- **No Cloud/Backend**: All processing happens locally
- **No AI**: Pure cryptographic operations
- **Privacy-First**: No data collection or tracking

### 📱 Core Functionality
- **Browser Tab**: Enter URLs and receive encrypted webpage content
- **History Tab**: View and manage browsing history
- **SMS Communication**: Requests and responses via encrypted SMS
- **Gateway Mode**: Fetch webpages for other devices
- **Client Mode**: Browse the web without internet

### 🎨 User Interface
- **Flat Design**: Clean, minimalist interface
- **Dark Mode**: AMOLED-optimized true black (#000000)
- **Light Mode**: Clean white interface (#FFFFFF)
- **Cupertino Icons**: Consistent iOS-style iconography
- **Theme-Aware**: Automatically follows system theme

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2+
- Android device (two phones for full functionality)
- SMS permissions

### Installation

1. **Clone the repository**
   ```bash
   cd linkless
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on device**
   ```bash
   flutter run
   ```

### Initial Setup

1. **On Both Devices**: Grant SMS permissions when prompted
2. **Client Device**: Enter Gateway phone number in Browser tab
3. **Start Browsing**: Enter a URL and tap send

---

## 📱 Usage

### Client Mode (Browsing)
1. Open the **Browser** tab
2. Enter a URL (e.g., `wikipedia.org`)
3. Tap the send button
4. Wait for encrypted response via SMS
5. View webpage content

### Gateway Mode
1. Install on internet-connected device
2. Keep app running in background
3. Automatically processes requests

---

## 📊 Development Status

**✅ 100% Complete** - All 8 phases implemented!

See `PROGRESS.md` for detailed development information.

---

## 🎨 Theme Specifications

**Dark Mode**: `#000000` background, `#B3FF9D` primary  
**Light Mode**: `#FFFFFF` background, `#07BDFF` primary

---

## 📄 License

Educational purposes project.

---

**Linkless Browser v1.0** - Encrypted SMS Web Browsing 🔐

## Quick Docs tweak
Updated docs for clarity.
