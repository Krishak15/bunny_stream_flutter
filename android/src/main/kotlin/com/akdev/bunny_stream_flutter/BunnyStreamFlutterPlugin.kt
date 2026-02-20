package com.akdev.bunny_stream_flutter

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import java.net.URLEncoder
import java.net.HttpURLConnection
import java.net.URL
import org.json.JSONObject

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
			"getVideo" -> handleGetVideo(call, result)
			"listVideos" -> handleListVideos(call, result)
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
		val token = call.argument<String>("token")?.trim()?.ifBlank { null }
		val expires = call.argument<Number>("expires")?.toLong()

		val playlistUrl = buildPlaybackUrl(
			baseUrl = "https://$host/$videoId/playlist.m3u8",
			token = token,
			expires = expires,
		)
		val fallbackUrl = buildPlaybackUrl(
			baseUrl = "https://$host/$videoId/play_720p.mp4",
			token = token,
			expires = expires,
		)
		val url360p = buildPlaybackUrl(
			baseUrl = "https://$host/$videoId/play_360p.mp4",
			token = token,
			expires = expires,
		)
		val url720p = buildPlaybackUrl(
			baseUrl = "https://$host/$videoId/play_720p.mp4",
			token = token,
			expires = expires,
		)
		val url1080p = buildPlaybackUrl(
			baseUrl = "https://$host/$videoId/play_1080p.mp4",
			token = token,
			expires = expires,
		)

		val payload = mapOf(
			"videoId" to videoId,
			"libraryId" to requestedLibraryId,
			"videoPlaylistUrl" to playlistUrl,
			"fallbackUrl" to fallbackUrl,
			"url360p" to url360p,
			"url720p" to url720p,
			"url1080p" to url1080p,
		)
		result.success(payload)
	}

	private fun handleGetVideo(call: MethodCall, result: MethodChannel.Result) {
		if (accessKey.isNullOrEmpty()) {
			result.error("NOT_INITIALIZED", "Call initialize() before requesting video metadata.", null)
			return
		}

		val requestedLibraryId = call.argument<Int>("libraryId")
		val videoId = call.argument<String>("videoId")?.trim()

		if (requestedLibraryId == null || requestedLibraryId <= 0) {
			result.error("INVALID_ARGUMENT", "libraryId must be a positive integer.", null)
			return
		}
		if (videoId.isNullOrEmpty()) {
			result.error("INVALID_ARGUMENT", "videoId is required.", null)
			return
		}

		val mainHandler = Handler(Looper.getMainLooper())
		Thread {
			try {
				val url = URL("https://video.bunnycdn.com/library/$requestedLibraryId/videos/$videoId")
				val connection = url.openConnection() as HttpURLConnection
				connection.requestMethod = "GET"
				connection.setRequestProperty("AccessKey", accessKey)
				connection.setRequestProperty("accept", "application/json")
				connection.connectTimeout = 10000
				connection.readTimeout = 10000

				val responseCode = connection.responseCode
				if (responseCode == HttpURLConnection.HTTP_OK) {
					val response = connection.inputStream.bufferedReader().use { it.readText() }
					val jsonObject = JSONObject(response)
					val videoMap = jsonObjectToMap(jsonObject)
					mainHandler.post {
						result.success(videoMap)
					}
				} else {
					val errorStream = connection.errorStream?.bufferedReader()?.use { it.readText() }
					mainHandler.post {
						result.error("API_ERROR", "Bunny API returned $responseCode: $errorStream", null)
					}
				}
				connection.disconnect()
			} catch (e: Exception) {
				mainHandler.post {
					result.error("NETWORK_ERROR", "Failed to fetch video: ${e.message}", null)
				}
			}
		}.start()
	}

	private fun handleListVideos(call: MethodCall, result: MethodChannel.Result) {
		if (accessKey.isNullOrEmpty()) {
			result.error("NOT_INITIALIZED", "Call initialize() before requesting videos.", null)
			return
		}

		val requestedLibraryId = call.argument<Int>("libraryId")
		val page = call.argument<Int>("page") ?: 1
		val itemsPerPage = call.argument<Int>("itemsPerPage") ?: 100
		val collectionId = call.argument<String>("collectionId")?.trim()

		if (requestedLibraryId == null || requestedLibraryId <= 0) {
			result.error("INVALID_ARGUMENT", "libraryId must be a positive integer.", null)
			return
		}

		val mainHandler = Handler(Looper.getMainLooper())
		Thread {
			try {
				var urlString = "https://video.bunnycdn.com/library/$requestedLibraryId/videos?page=$page&itemsPerPage=$itemsPerPage"
				if (!collectionId.isNullOrEmpty()) {
					urlString += "&collectionId=$collectionId"
				}

				val url = URL(urlString)
				val connection = url.openConnection() as HttpURLConnection
				connection.requestMethod = "GET"
				connection.setRequestProperty("AccessKey", accessKey)
				connection.setRequestProperty("accept", "application/json")
				connection.connectTimeout = 10000
				connection.readTimeout = 10000

				val responseCode = connection.responseCode
				if (responseCode == HttpURLConnection.HTTP_OK) {
					val response = connection.inputStream.bufferedReader().use { it.readText() }
					val jsonObject = JSONObject(response)
					val itemsList = jsonObject.optJSONArray("items") ?: jsonObject.optJSONArray("results")
					val videos = mutableListOf<Map<String, Any?>>()

					if (itemsList != null) {
						for (i in 0 until itemsList.length()) {
							val item = itemsList.getJSONObject(i)
							videos.add(jsonObjectToMap(item))
						}
					}

					mainHandler.post {
						result.success(videos)
					}
				} else {
					val errorStream = connection.errorStream?.bufferedReader()?.use { it.readText() }
					mainHandler.post {
						result.error("API_ERROR", "Bunny API returned $responseCode: $errorStream", null)
					}
				}
				connection.disconnect()
			} catch (e: Exception) {
				mainHandler.post {
					result.error("NETWORK_ERROR", "Failed to fetch videos: ${e.message}", null)
				}
			}
		}.start()
	}

	private fun jsonObjectToMap(json: JSONObject): Map<String, Any?> {
		val map = mutableMapOf<String, Any?>()
		val keys = json.keys()
		while (keys.hasNext()) {
			val key = keys.next()
			var value: Any? = json.get(key)
			if (value is JSONObject) {
				value = jsonObjectToMap(value)
			} else if (value is JSONArray) {
				value = jsonArrayToList(value)
			}
			map[key] = value
		}
		return map
	}

	private fun jsonArrayToList(array: JSONArray): List<Any?> {
		val list = mutableListOf<Any?>()
		for (i in 0 until array.length()) {
			var value: Any? = array.get(i)
			if (value is JSONObject) {
				value = jsonObjectToMap(value)
			} else if (value is JSONArray) {
				value = jsonArrayToList(value)
			}
			list.add(value)
		}
		return list
	}

	private fun buildPlaybackUrl(
		baseUrl: String,
		token: String?,
		expires: Long?,
	): String {
		if (token.isNullOrEmpty() && expires == null) return baseUrl

		val queryParams = mutableListOf<String>()
		if (!token.isNullOrEmpty()) {
			queryParams.add("token=${URLEncoder.encode(token, Charsets.UTF_8.name())}")
		}
		if (expires != null) {
			queryParams.add("expires=$expires")
		}

		if (queryParams.isEmpty()) return baseUrl
		val separator = if (baseUrl.contains('?')) "&" else "?"
		return "$baseUrl$separator${queryParams.joinToString("&")}"
	}
}
