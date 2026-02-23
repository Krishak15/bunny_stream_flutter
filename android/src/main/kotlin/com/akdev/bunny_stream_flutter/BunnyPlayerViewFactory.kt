package com.akdev.bunny_stream_flutter

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class BunnyPlayerViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context, id: Int, args: Any?): PlatformView {
    @Suppress("UNCHECKED_CAST")
    val creationParams = args as? Map<String, Any?>
    return BunnyPlayerPlatformView(context, creationParams)
  }
}
