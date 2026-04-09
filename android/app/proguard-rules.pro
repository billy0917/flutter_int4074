# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Sherpa ONNX - native JNI bindings
-keep class com.k2fsa.sherpa.onnx.** { *; }
-keepclassmembers class com.k2fsa.sherpa.onnx.** { *; }

# Record plugin
-keep class com.llfbandit.record.** { *; }

# Hive
-keep class ** extends com.google.protobuf.GeneratedMessageLite { *; }
-keepclassmembers class * implements java.io.Serializable { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
