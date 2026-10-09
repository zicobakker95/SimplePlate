# flutter_local_notifications caches every scheduled notification as JSON
# through Gson. R8 strips the generic type signatures Gson reads back, so
# scheduling throws PlatformException("Missing type parameter") in release
# builds only -- debug builds are never shrunk, which is why it only ever
# showed up in Crashlytics. Rules from the plugin's README (which points at
# Gson's own proguard.cfg) plus the plugin's model classes.

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# flutter_local_notifications models (serialised by Gson)
-keep class com.dexterous.** { *; }

# --- AdMob bidding mediation (Unity Ads, Liftoff Monetize) ----------------
# The Google Mobile Ads SDK instantiates mediation adapters by class name from
# the server-side mediation config, so nothing in the app references them
# directly. If R8 renames or strips one, that network silently never bids in
# release builds while debug (unshrunk) looks fine. The SDKs ship consumer
# rules of their own; these are a belt-and-braces backstop.
-keep class com.google.ads.mediation.** { *; }
-keep class * implements com.google.android.gms.ads.mediation.MediationAdapter { *; }
-keep class * extends com.google.android.gms.ads.mediation.Adapter { *; }
# Liftoff Monetize (Vungle)
-keep class com.vungle.** { *; }
-dontwarn com.vungle.**
# Unity Ads
-keep class com.unity3d.ads.** { *; }
-keep class com.unity3d.services.** { *; }
-dontwarn com.unity3d.**
-dontwarn com.google.ar.core.**
-dontwarn com.ironsource.adapters.unityads.**
