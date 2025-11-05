package com.example.linkless

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsManager
import android.util.Log
import org.jsoup.Jsoup
import java.util.Base64

/**
 * SmsReceiver handles incoming SMS messages for the Gateway device
 * Processes encrypted SMS requests and sends back encrypted web content
 * 
 * Note: This receiver is designed for Gateway mode operation
 * The actual encryption/decryption should be coordinated with Flutter's CryptoService
 */
class SmsReceiver : BroadcastReceiver() {
    private val tag = "LinklessSmsReceiver"
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            
            if (messages.isNullOrEmpty()) {
                Log.w(tag, "No SMS messages received")
                return
            }
            
            // Process the first message
            val message = messages[0]
            val sender = message.originatingAddress ?: return
            val messageBody = message.messageBody ?: return
            
            Log.d(tag, "Received SMS from: $sender")
            
            // Check if it's a Linkless request (starts with "LK:")
            if (messageBody.startsWith("LK:")) {
                processLinklessRequest(sender, messageBody, context)
            } else {
                Log.d(tag, "Not a Linkless message, ignoring")
            }
        }
    }
    
    /**
     * Process a Linkless SMS request
     * Extract URL, fetch content, and send back encrypted reply
     */
    private fun processLinklessRequest(sender: String, messageBody: String, context: Context) {
        Thread {
            try {
                // Remove "LK:" prefix
                val encryptedUrl = messageBody.substring(3)
                
                // TODO: Decrypt the URL using CryptoService
                // For now, we'll assume the URL is passed as-is for testing
                // In production, this should decrypt using shared secret
                val url = decryptMessage(encryptedUrl)
                
                Log.d(tag, "Fetching URL: $url")
                
                // Fetch web page content
                val webContent = fetchWebContent(url)
                
                Log.d(tag, "Fetched ${webContent.length} characters")
                
                // TODO: Encrypt the response using CryptoService
                // For now, we'll send as-is for testing
                val encryptedResponse = encryptMessage(webContent)
                
                // Send SMS reply
                sendSmsReply(sender, encryptedResponse)
                
                Log.d(tag, "Sent reply to: $sender")
                
            } catch (e: Exception) {
                Log.e(tag, "Error processing Linkless request: ${e.message}", e)
                
                // Send error message back
                try {
                    val errorMsg = "Error: ${e.message?.take(100) ?: "Unknown error"}"
                    sendSmsReply(sender, errorMsg)
                } catch (sendError: Exception) {
                    Log.e(tag, "Failed to send error SMS: ${sendError.message}")
                }
            }
        }.start()
    }
    
    /**
     * Fetch web page content using Jsoup
     * Limits to 1200 characters for SMS compatibility
     */
    private fun fetchWebContent(url: String): String {
        // Ensure URL has protocol
        val normalizedUrl = if (!url.startsWith("http://") && !url.startsWith("https://")) {
            "https://$url"
        } else {
            url
        }
        
        val document = Jsoup.connect(normalizedUrl)
            .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
            .timeout(15000)
            .get()
        
        val bodyText = document.body().text()
        
        // Limit to 1200 characters
        return if (bodyText.length > 1200) {
            bodyText.substring(0, 1200) + "..."
        } else {
            bodyText
        }
    }
    
    /**
     * Send SMS reply
     */
    private fun sendSmsReply(recipient: String, message: String) {
        val smsManager = SmsManager.getDefault()
        
        // Split message if it's too long (SMS limit is ~160 characters)
        val parts = smsManager.divideMessage(message)
        
        if (parts.size == 1) {
            smsManager.sendTextMessage(recipient, null, message, null, null)
        } else {
            smsManager.sendMultipartTextMessage(recipient, null, parts, null, null)
        }
    }
    
    /**
     * Decrypt incoming message
     * TODO: Implement actual decryption using CryptoService via Flutter
     * For now, this is a placeholder that assumes base64 encoding
     */
    private fun decryptMessage(encryptedMessage: String): String {
        return try {
            // Placeholder: Just decode base64 for testing
            // In production, this should call Flutter's CryptoService
            val decoded = Base64.getDecoder().decode(encryptedMessage)
            String(decoded)
        } catch (e: Exception) {
            Log.w(tag, "Decryption placeholder - using message as-is")
            encryptedMessage
        }
    }
    
    /**
     * Encrypt outgoing message
     * TODO: Implement actual encryption using CryptoService via Flutter
     * For now, this is a placeholder that uses base64 encoding
     */
    private fun encryptMessage(plaintext: String): String {
        return try {
            // Placeholder: Just encode as base64 for testing
            // In production, this should call Flutter's CryptoService
            Base64.getEncoder().encodeToString(plaintext.toByteArray())
        } catch (e: Exception) {
            Log.w(tag, "Encryption placeholder - using plaintext")
            plaintext
        }
    }
}
