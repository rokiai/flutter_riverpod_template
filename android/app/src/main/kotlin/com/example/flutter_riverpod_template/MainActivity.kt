package com.example.flutter_riverpod_template

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/// Flutter 在 Android 上的入口 Activity。
class MainActivity : FlutterActivity() {
    /// 引擎就绪后立刻挂上 Pigeon HostApi，避免 Dart 首帧调用时通道还没注册。
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AppPlatformHostApi.setUp(
            flutterEngine.dartExecutor.binaryMessenger,
            object : AppPlatformHostApi {
                override fun getPlatformVersion(): String =
                    "Android ${Build.VERSION.RELEASE}"
            },
        )
    }
}
