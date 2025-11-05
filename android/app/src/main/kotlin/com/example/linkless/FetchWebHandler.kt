package com.example.linkless

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.jsoup.Jsoup
import org.jsoup.HttpStatusException
import java.io.IOException

/**
 * FetchWebHandler handles web page fetching via Jsoup
 * Communicates with Flutter via MethodChannel
 */
class FetchWebHandler(flutterEngine: FlutterEngine) {
    private val channelName = "linkless_gateway"
    
    init {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "fetchWeb" -> {
                        val url = call.argument<String>("url")
                        if (url != null) {
                            fetchWebPage(url, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "URL is required", null)
                        }
                    }
                    "ping" -> {
                        result.success("pong")
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
    
    /**
     * Fetch web page content using Jsoup
     * Extracts plain text from the page body
     * Limits output to 1200 characters for SMS compatibility
     */
    private fun fetchWebPage(url: String, result: MethodChannel.Result) {
        Thread {
            try {
                // Ensure URL has protocol
                val normalizedUrl = if (!url.startsWith("http://") && !url.startsWith("https://")) {
                    "https://$url"
                } else {
                    url
                }
                
                // Fetch the webpage
                val document = Jsoup.connect(normalizedUrl)
                    .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
                    .timeout(15000) // 15 second timeout
                    .get()
                
                // Extract text from body
                val bodyText = document.body().text()
                
                // Limit to 1200 characters for SMS
                val limitedText = if (bodyText.length > 1200) {
                    bodyText.substring(0, 1200) + "..."
                } else {
                    bodyText
                }
                
                result.success(limitedText)
                
            } catch (e: HttpStatusException) {
                result.error(
                    "HTTP_ERROR",
                    "HTTP ${e.statusCode}: ${e.message}",
                    null
                )
            } catch (e: IOException) {
                result.error(
                    "NETWORK_ERROR",
                    "Failed to fetch page: ${e.message}",
                    null
                )
            } catch (e: Exception) {
                result.error(
                    "FETCH_ERROR",
                    "Error fetching web page: ${e.message}",
                    null
                )
            }
        }.start()
    }
}
