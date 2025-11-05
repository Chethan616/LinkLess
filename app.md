This is a well-structured and comprehensive build specification for Linkless Browser v1! It's clear, detailed, and provides all the necessary information for a developer (or an AI assistant like Copilot) to understand and implement the project.

Here's how I would present this as a "good app.md" file, making sure all the key information is highlighted and easy to digest for Copilot or any developer. I'll maintain the existing structure and content, with minor formatting adjustments and emphasis for clarity.

📱 Linkless Browser v1 — Final Build Specification
🚀 Encrypted SMS Web Browsing for Everyone!

This document outlines the complete specifications for Linkless Browser v1, a unique application designed for secure, internet-free web browsing via encrypted SMS. Our goal is to create a robust, privacy-focused tool that leverages existing mobile infrastructure for discreet web access.

Key Principle: No AI, no cloud, no backend. Just pure, end-to-end encrypted SMS communication for web content retrieval.

💡 Overview & Core Concept

Linkless Browser operates on a two-phone model:

Client Phone (No Internet): Sends encrypted SMS requests for URLs and receives encrypted webpage content.

Gateway Phone (With Internet): Acts as a relay, fetching web pages and sending the textual content back via encrypted SMS.

How it Works in a Nutshell:

Client sends LK: encrypted_url to Gateway.

Gateway decrypts, fetches URL via Jsoup, extracts text.

Gateway encrypts text and sends it back to Client.

Client decrypts and displays the web content.

🏗️ Project Structure

The project will follow a standard Flutter + Kotlin architecture:

code
Code
download
content_copy
expand_less
linkless/
 ├── lib/
 │   ├── main.dart             # Main Flutter entry point
 │   ├── core/
 │   │   ├── theme.dart        # UI theming (Dark/Light)
 │   │   └── colors.dart       # Color definitions
 │   ├── services/
 │   │   ├── sms_service.dart  # Handles SMS sending/receiving in Dart
 │   │   ├── crypto_service.dart # Handles all encryption/decryption
 │   │   └── platform_bridge.dart # MethodChannel communication with Kotlin
 │   ├── ui/
 │   │   ├── screens/
 │   │   │   ├── home_screen.dart # Main screen with tabs
 │   │   │   ├── browser_tab.dart # UI for URL input and result display
 │   │   │   └── history_tab.dart # UI for browsing history
 │   │   └── widgets/
 │   │       ├── message_bubble.dart # Placeholder for message display
 │   │       └── input_field.dart # Reusable input component
 └── android/
     ├── kotlin/
     │   ├── SmsReceiver.kt       # Android BroadcastReceiver for incoming SMS
     │   ├── FetchWebHandler.kt   # Kotlin module for Jsoup web fetching
     │   └── MainActivity.kt      # Main Android activity
     └── AndroidManifest.xml      # App permissions and declarations
✨ Core Functionality
Client App Features:

Two Primary Tabs:

Browser Tab: For entering URLs, sending requests, and displaying received webpage text.

History Tab: Stores and displays a local list of previously browsed URLs.

End-to-End Encryption:

Encrypts outgoing messages using AES-GCM (256-bit).

Decrypts incoming replies using AES-GCM (256-bit).

Uses X25519 for secure shared session key exchange.

Gateway App Features:

SMS Listener: Continuously listens for incoming SMS messages.

Request Processing:

Decrypts incoming SMS to extract the requested URL.

Fetches the webpage content using the Jsoup library.

Extracts the plain text body of the webpage (up to 1200 characters).

Reply Generation:

Encrypts the extracted webpage text.

Sends the encrypted text back to the original sender via SMS.

Offline Capability: The Gateway functions without a continuous internet connection, only needing it for the moment of fetching a webpage.

🔒 Encryption Protocol (End-to-End)

A robust, multi-layered encryption scheme ensures privacy and security.

Layer	Algorithm	Notes
Key Exchange	X25519	Securely establishes a shared secret key.
Symmetric Cipher	AES-GCM (256-bit)	Encrypts the actual message content.
Encoding	Base64	Encodes binary encrypted data for SMS transmission.
Compression	None	Simplifies implementation for v1.
🎨 UI Design Guidelines

A clean, flat, and performance-optimized UI is paramount.

Mode	Background	Primary Color	Text Color
Dark Mode	#000000	#B3FF9D	#FFFFFF
Light Mode	#FFFFFF	#07BDFF	#000000

Style Notes:

Flat Design: Emphasize simplicity and directness.

No Gradients: Keep colors solid and clean.

AMOLED Optimized Dark Mode: Utilize true black for energy efficiency on AMOLED screens.

Icons: Exclusively use CupertinoIcons.

📦 Dependencies
Flutter Packages (pubspec.yaml):
code
Yaml
download
content_copy
expand_less
dependencies:
  flutter:
    sdk: flutter
  telephony: ^0.2.0        # For SMS handling (send/receive)
  cryptography: ^3.0.0     # For X25519 and AES-GCM encryption
  cupertino_icons: ^1.0.8  # Apple-style icons
Android Dependencies (android/app/build.gradle):
code
Gradle
download
content_copy
expand_less
implementation 'org.jsoup:jsoup:1.16.1' # For web page parsing
🛡️ Android Permissions (AndroidManifest.xml)

The following permissions are critical for SMS and internet functionality:

code
Xml
download
content_copy
expand_less
<uses-permission android:name="android.permission.SEND_SMS"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>
<uses-permission android:name="android.permission.INTERNET"/>
🤝 Component Responsibilities
Flutter (Dart) Responsibilities:

User Interface: All UI elements (tabs, input fields, display areas).

SMS Interaction: Initiating SMS sends and handling incoming SMS messages.

Cryptographic Operations: Performing AES-GCM encryption/decryption and X25519 key exchange.

History Management: Saving and displaying recent URL requests.

Kotlin Responsibilities:

SMS Reception: Acting as an SMS BroadcastReceiver to intercept incoming messages.

Message Parsing: Extracting raw message body.

Web Page Fetching: Utilizing Jsoup to connect to URLs and extract plain text.

SMS Transmission: Sending SMS replies.

🔄 Data Flow Walkthrough

A clear understanding of the data journey is crucial for implementation.

1. Client → Gateway (Request)

Client: "wikipedia.org"
Action: Encrypt("wikipedia.org") → Base64Encode() → telephony.sendSms(to: Gateway_Number, message: "LK:Base64Encoded_Encrypted_URL")

2. Gateway Processing

Action: SmsReceiver intercepts SMS → Base64Decode() → Decrypt(Base64Decoded_Encrypted_URL) → Extracts URL ("wikipedia.org") → Jsoup.connect(URL).get().body().text().take(1200) → extracted_text

3. Gateway → Client (Reply)

Action: Encrypt(extracted_text) → Base64Encode() → SmsManager.getDefault().sendTextMessage(to: Client_Number, message: "Base64Encoded_Encrypted_Text")

4. Client Display

Action: telephony.listenIncomingSms intercepts SMS → Base64Decode() → Decrypt(Base64Decoded_Encrypted_Text) → display_text

🖼️ UI Structure Details
Home Screen:

Top Bar: Contains a TabBar with two selectable tabs: "Browser" and "History".

Body: Displays the content of the currently selected tab.

Browser Tab:

URL Input: A TextField for users to type or paste a URL.

Send Button: A CupertinoIcons.arrow_up_circle_fill icon button to initiate the SMS request.

Results Area: A Scrollable TextView (or similar widget) to display the decrypted webpage text received from the Gateway.

History Tab:

List View: A ListView to show a chronological list of previously requested URLs.

Delete Icon: Each history item should have a CupertinoIcons.trash icon to remove it from the list.

⚡ Build Steps

Follow these steps to set up the project:

Create Flutter Project:

code
Bash
download
content_copy
expand_less
flutter create linkless

Add Dependencies: Update pubspec.yaml with the Flutter packages and android/app/build.gradle with the Jsoup dependency.

Kotlin Support: Ensure Kotlin is correctly configured for the Android module (default in new Flutter projects).

Implement Platform Channel: Create the MethodChannel between Dart (platform_bridge.dart) and Kotlin (FetchWebHandler.kt).

Configure Android Permissions: Add the necessary permissions to AndroidManifest.xml.

Develop & Test: Implement the Flutter UI, Dart SMS/Crypto logic, and Kotlin SMS/Web fetching logic. Thoroughly test with two physical Android devices.

🧩 Kotlin Code Examples
FetchWebHandler.kt (for web fetching via MethodChannel)
code
Kotlin
download
content_copy
expand_less
package com.example.linkless

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.jsoup.Jsoup

class FetchWebHandler(flutterEngine: FlutterEngine) {
    init {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "linkless_gateway")
            .setMethodCallHandler { call, result ->
                if (call.method == "fetchWeb") {
                    val url = call.argument<String>("url")
                    // Fetch web page and extract text, limit to 1200 chars for SMS
                    val text = Jsoup.connect(url!!).get().body().text().take(1200)
                    result.success(text)
                } else {
                    result.notImplemented()
                }
            }
    }
}
SmsReceiver.kt (for direct SMS processing on Gateway)
code
Kotlin
download
content_copy
expand_less
package com.example.linkless // Ensure this matches your package name

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsManager
import android.provider.Telephony
import org.jsoup.Jsoup

class SmsReceiver : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    // Check if the intent is for SMS_RECEIVED_ACTION
    if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
        val msgs = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (msgs != null && msgs.isNotEmpty()) {
            val msgBody = msgs[0].messageBody
            val sender = msgs[0].originatingAddress

            // --- IMPORTANT: Placeholder for actual decryption and encryption ---
            // TODO: Implement the crypto_service.decrypt function here using a shared key
            // This will involve communicating with the Flutter side to get keys or performing crypto directly in Kotlin.
            // For now, assuming a simple prefix removal.
            val decryptedUrl = if (msgBody.startsWith("LK:")) {
                msgBody.removePrefix("LK:")
            } else {
                msgBody // Or handle as an error/unrecognized format
            }

            // Fetch content from the URL
            val text = try {
                // Ensure URL is valid before connecting
                Jsoup.connect(decryptedUrl).get().body().text().take(1200)
            } catch (e: Exception) {
                "Error fetching $decryptedUrl: ${e.localizedMessage}"
            }

            // TODO: Implement the crypto_service.encrypt function here using a shared key
            // This will encrypt 'text' before sending.
            val encryptedResponse = text // Placeholder: should be actual encrypted text

            // Send back the (encrypted) response
            SmsManager.getDefault().sendTextMessage(sender, null, encryptedResponse, null, null)
        }
    }
  }
}
🧩 Flutter Code Examples
SMS Sending (sms_service.dart)
code
Dart
download
content_copy
expand_less
import 'package:telephony/telephony.dart';
import 'package:linkless/services/crypto_service.dart'; // Import your crypto service

final telephony = Telephony.instance;
final String gatewayPhoneNumber = "+1234567890"; // TODO: Replace with actual Gateway phone number

Future<void> sendRequest(String url) async {
  final encrypted = await CryptoService.encrypt(url); // AES-GCM encryption
  telephony.sendSms(
    to: gatewayPhoneNumber,
    message: "LK:$encrypted", // Prefix for Linkless messages
  );
  print('Sent SMS request: LK:$encrypted');
}
SMS Receiving (sms_service.dart or home_screen.dart)
code
Dart
download
content_copy
expand_less
import 'package:telephony/telephony.dart';
import 'package:linkless/services/crypto_service.dart'; // Import your crypto service

// This should typically be initialized in a StatefulWidget's initState or similar
void initializeSmsReceiver(Function(String) onNewDecryptedMessage) {
  telephony.listenIncomingSms(
    onNewMessage: (SmsMessage msg) async {
      print('Received SMS: ${msg.body}');
      if (msg.body != null) {
        // Assume all incoming messages are responses for now, or add a prefix check
        final decrypted = await CryptoService.decrypt(msg.body!);
        onNewDecryptedMessage(decrypted);
        print('Decrypted message: $decrypted');
      }
    },
    listenInBackground: false, // Set to true if you need background listening
  );
}
Encryption/Decryption (crypto_service.dart)
code
Dart
download
content_copy
expand_less
import 'package:cryptography/cryptography.dart';
import 'dart:convert';

// This service will manage all cryptographic operations
class CryptoService {
  static final algorithm = AesGcm.with256bits();
  static final x25519 = X25519();

  // TODO: Implement secure storage and retrieval for client/gateway key pairs
  // For now, simple placeholders for key management.
  static SimpleKeyPair? _clientKeyPair;
  static SimpleKeyPair? _gatewayPublicKey; // Client stores Gateway's public key
  static SecretKey? _sharedSecretKey;

  // Initialize keys (needs to be called once, e.g., on app start)
  static Future<void> initializeKeys() async {
    // Generate client's key pair (if not already stored)
    _clientKeyPair ??= await x25519.newKeyPair();
    
    // In a real app, the client would send its public key to the gateway,
    // and the gateway would send its public key to the client for exchange.
    // For this build spec, we assume some out-of-band exchange or pre-configuration.
    
    // Placeholder: Gateway's public key (replace with actual key exchange)
    _gatewayPublicKey ??= SimplePublicKey(
      List.generate(32, (index) => index), // Example: a dummy public key
      algorithm: x25519,
    );

    // Derive shared secret key
    _sharedSecretKey = await x25519.sharedSecretKey(
      keyPair: _clientKeyPair!,
      remotePublicKey: _gatewayPublicKey!,
    );
  }

  // Encrypts a message using AES-GCM with the shared secret key
  static Future<String> encrypt(String message) async {
    if (_sharedSecretKey == null) {
      await initializeKeys(); // Ensure keys are initialized
    }
    final nonce = algorithm.newNonce(); // Generate a new random nonce for each encryption
    final secretBox = await algorithm.encrypt(
      utf8.encode(message),
      secretKey: _sharedSecretKey!,
      nonce: nonce,
    );
    // Concatenate nonce, ciphertext, and MAC for transmission
    return base64Encode(secretBox.concatenation());
  }

  // Decrypts an encoded message using AES-GCM with the shared secret key
  static Future<String> decrypt(String encoded) async {
    if (_sharedSecretKey == null) {
      await initializeKeys(); // Ensure keys are initialized
    }
    final bytes = base64Decode(encoded);
    // Extract nonce, ciphertext, and MAC from the concatenated bytes
    final secretBox = SecretBox.fromConcatenation(bytes, nonceLength: 12, macLength: 16);
    final clear = await algorithm.decrypt(secretBox, secretKey: _sharedSecretKey!);
    return utf8.decode(clear);
  }
}
🧩 Theming (core/theme.dart)
code
Dart
download
content_copy
expand_less
import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  primaryColor: const Color(0xFF07BDFF),
  // Define text themes and other component themes
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF07BDFF),
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF07BDFF)),
  // Add more theming for specific components as needed
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF000000),
  primaryColor: const Color(0xFFB3FF9D),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFB3FF9D),
    foregroundColor: Colors.black,
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFB3FF9D)),
  // Add more theming for specific components as needed
);
✅ Project Summary
Feature	Detail
App Name	Linkless Browser
Purpose	SMS-based, encrypted text web browser
Technologies	Flutter (Dart) + Kotlin
Encryption	AES-GCM (E2E) with X25519 key exchange
UI Colors	Dark: #000000 bg / #B3FF9D primary<br>Light: #FFFFFF bg / #07BDFF primary
UI Icons	Cupertino Icons only
Navigation	Browser tab / History tab
Gateway Function	Fetches web pages via Jsoup, sends encrypted SMS
Client Function	Browses web via encrypted SMS requests/responses

This detailed specification provides a clear roadmap for building Linkless Browser v1. Let's make it a fantastic and secure communication tool!