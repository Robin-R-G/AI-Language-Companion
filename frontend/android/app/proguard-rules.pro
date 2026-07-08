# ProGuard rules for AI Language Coach
# Keep annotations for Flutter plugins

# ── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Firebase ─────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── Google AdMob ─────────────────────────────────────────────────────────────
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ── Google Sign-In ───────────────────────────────────────────────────────────
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# ── Stripe ───────────────────────────────────────────────────────────────────
-keep class com.stripe.android.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }
-dontwarn com.stripe.android.**

# ── Razorpay ─────────────────────────────────────────────────────────────────
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# ── Sentry ───────────────────────────────────────────────────────────────────
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# ── LiveKit / WebRTC ────────────────────────────────────────────────────────
-keep class io.livekit.** { *; }
-keep class org.webrtc.** { *; }
-dontwarn io.livekit.**
-dontwarn org.webrtc.**

# ── Supabase ─────────────────────────────────────────────────────────────────
-keep class io.github.jan-tennert.supabase.** { *; }
-dontwarn io.github.jan-tennert.supabase.**

# ── SQLite / sqflite ────────────────────────────────────────────────────────
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
-dontwarn org.sqlite.**

# ── Image Picker ─────────────────────────────────────────────────────────────
-keep class androidx.exifinterface.** { *; }
-dontwarn androidx.exifinterface.**

# ── WebView ──────────────────────────────────────────────────────────────────
-keep class org.chromium.** { *; }
-dontwarn org.chromium.**

# ── Kotlin Serialization ─────────────────────────────────────────────────────
-keep class kotlin.reflect.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.reflect.**

# ── Freezed / JSON Serializable ──────────────────────────────────────────────
-keep class com.freezed.** { *; }
-keep class **.g.dart { *; }
-keep class **.freezed.dart { *; }

# ── Hive ─────────────────────────────────────────────────────────────────────
-keep class io.hive.** { *; }
-dontwarn io.hive.**

# ── Shared Preferences ───────────────────────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ── Permission Handler ───────────────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ── Device Info ──────────────────────────────────────────────────────────────
-keep class com.baseflow.deviceinfoplus.** { *; }

# ── URL Launcher ─────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.urllauncher.** { *; }

# ── Play Core (deferred components) ─────────────────────────────────────────
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# ── General ──────────────────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Exceptions,InnerClasses
