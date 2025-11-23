# --- 1. RULES FLUTTER LOCAL NOTIFICATIONS ---
# Wajib untuk versi plugin di bawah v19 (kita pakai v17)
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }

# --- 2. RULES GSON (OFFICIAL) ---
# Mengatasi error "Missing type parameter" dengan menjaga Signature Generics
-keepattributes Signature

# Menjaga anotasi seperti @SerializedName
-keepattributes *Annotation*

# Mencegah warning pada class sun.misc
-dontwarn sun.misc.**

# Menjaga struktur dasar Gson agar tidak dibuang R8
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Mencegah R8 membuang field yang dipakai Gson
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Menjaga TypeToken (Penyebab utama crash di release jika hilang)
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# --- 3. RULES UMUM ANDROID ---
-keep public class * extends android.app.Activity