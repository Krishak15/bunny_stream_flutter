package com.akdev.bunny_stream_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BunnyStreamFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
	private lateinit var channel: MethodChannel
	private var accessKey: String? = null
	private var libraryId: Int? = null
	private var cdnHostname: String? = null

	override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
		channel = MethodChannel(binding.binaryMessenger, "bunny_stream_flutter")
		channel.setMethodCallHandler(this)
	}

	override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
		channel.setMethodCallHandler(null)
	}

	override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
		when (call.method) {
			"getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
			"initialize" -> handleInitialize(call, result)
			"listVideos",
			"getVideo",
			"listCollections",
			"getCollection" -> result.error(
				"UNIMPLEMENTED_NATIVE",
				"Native Bunny SDK integration for ${call.method} is not implemented yet on Android.",
				null,
			)

			"getVideoPlayData" -> handleGetVideoPlayData(call, result)
			else -> result.notImplemented()
		}
	}

	private fun handleInitialize(call: MethodCall, result: MethodChannel.Result) {
		val key = call.argument<String>("accessKey")?.trim()
		val library = call.argument<Int>("libraryId")
		val cdn = call.argument<String>("cdnHostname")?.trim()?.ifBlank { null }

		if (key.isNullOrEmpty()) {
			result.error("INVALID_ARGUMENT", "accessKey is required.", null)
			return
		}

		if (library == null || library <= 0) {
			result.error("INVALID_ARGUMENT", "libraryId must be a positive integer.", null)
			return
		}

		accessKey = key
		libraryId = library
		cdnHostname = cdn
		result.success(null)
	}

	private fun handleGetVideoPlayData(call: MethodCall, result: MethodChannel.Result) {
		if (accessKey.isNullOrEmpty() || libraryId == null) {
			result.error("NOT_INITIALIZED", "Call initialize() before requesting play data.", null)
			return
		}

		val videoId = call.argument<String>("videoId")?.trim()
		val requestedLibraryId = call.argument<Int>("libraryId")
		if (videoId.isNullOrEmpty()) {
			result.error("INVALID_ARGUMENT", "videoId is required.", null)
			return
		}
		if (requestedLibraryId == null || requestedLibraryId <= 0) {
			result.error("INVALID_ARGUMENT", "libraryId must be a positive integer.", null)
			return
		}

		val host = cdnHostname?.takeIf { it.isNotBlank() } ?: "vz-${requestedLibraryId}.b-cdn.net"
		val payload = mapOf(
			"videoId" to videoId,
			"libraryId" to requestedLibraryId,
			"videoPlaylistUrl" to "https://$host/$videoId/playlist.m3u8",
			"fallbackUrl" to "https://$host/$videoId/play_720p.mp4",
		)
		result.success(payload)
	}
}
