# Jsoup ProGuard Rules
-dontwarn org.jsoup.**
-keep class org.jsoup.** { *; }
-keepclassmembers class org.jsoup.** { *; }

# Keep javax annotations
-dontwarn javax.annotation.**
-keep class javax.annotation.** { *; }

# Keep all model classes
-keep class com.example.linkless.** { *; }
