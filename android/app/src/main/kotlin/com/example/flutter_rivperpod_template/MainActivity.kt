package com.example.flutter_rivperpod_template

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
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
