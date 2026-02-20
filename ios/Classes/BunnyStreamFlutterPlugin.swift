import Flutter
import UIKit

/// iOS implementation for the bunny_stream_flutter method channel.
///
/// Responsibilities:
/// - Persist initialization state (`accessKey`, `libraryId`, optional `cdnHostname`)
/// - Handle metadata/listing calls against Bunny management API
/// - Build playback URLs (with optional `token` and `expires`)
///
/// Supported methods:
/// - initialize
/// - getVideo
/// - listVideos
/// - getVideoPlayData
/// - getPlatformVersion
///
/// Not implemented natively yet:
/// - listCollections
/// - getCollection
public class BunnyStreamFlutterPlugin: NSObject, FlutterPlugin {
  /// Bunny Stream management API access key set during initialize.
  private var accessKey: String?
  /// Default Bunny library id set during initialize.
  private var libraryId: Int?
  /// Optional custom CDN host used for playback URL generation.
  private var cdnHostname: String?

  /// Registers the plugin as the method call delegate on the shared channel.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "bunny_stream_flutter", binaryMessenger: registrar.messenger())
    let instance = BunnyStreamFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Dispatches incoming Flutter method calls to concrete native handlers.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      handleInitialize(call, result: result)
    case "getVideo":
      handleGetVideo(call, result: result)
    case "listVideos":
      handleListVideos(call, result: result)
    case "listCollections", "getCollection":
      result(
        FlutterError(
          code: "UNIMPLEMENTED_NATIVE",
          message: "Native Bunny SDK integration for \(call.method) is not implemented yet on iOS.",
          details: nil
        )
      )
    case "getVideoPlayData":
      handleGetVideoPlayData(call, result: result)
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Validates and stores initialization arguments required by other methods.
  ///
  /// Required args:
  /// - accessKey: String
  /// - libraryId: Int (> 0)
  ///
  /// Optional args:
  /// - cdnHostname: String
  private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(
        FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are required.", details: nil))
      return
    }

    let key = (args["accessKey"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let library = args["libraryId"] as? Int
    let cdn = (args["cdnHostname"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)

    guard let key, !key.isEmpty else {
      result(
        FlutterError(code: "INVALID_ARGUMENT", message: "accessKey is required.", details: nil))
      return
    }

    guard let library, library > 0 else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENT", message: "libraryId must be a positive integer.", details: nil))
      return
    }

    accessKey = key
    libraryId = library
    cdnHostname = cdn?.isEmpty == true ? nil : cdn
    result(nil)
  }

  /// Builds and returns playback URLs for HLS and MP4 renditions.
  ///
  /// This method is deterministic and does not perform an API request.
  private func handleGetVideoPlayData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard accessKey != nil, libraryId != nil else {
      result(
        FlutterError(
          code: "NOT_INITIALIZED", message: "Call initialize() before requesting play data.",
          details: nil))
      return
    }

    guard let args = call.arguments as? [String: Any] else {
      result(
        FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are required.", details: nil))
      return
    }

    let videoId = (args["videoId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let requestedLibraryId = args["libraryId"] as? Int
    let token = (args["token"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let expires = args["expires"] as? Int

    guard let videoId, !videoId.isEmpty else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "videoId is required.", details: nil))
      return
    }

    guard let requestedLibraryId, requestedLibraryId > 0 else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENT", message: "libraryId must be a positive integer.", details: nil))
      return
    }

    let host = (cdnHostname?.isEmpty == false ? cdnHostname! : "vz-\(requestedLibraryId).b-cdn.net")
    let playlistUrl = buildPlaybackUrl(
      baseUrl: "https://\(host)/\(videoId)/playlist.m3u8",
      token: token,
      expires: expires
    )
    let fallbackUrl = buildPlaybackUrl(
      baseUrl: "https://\(host)/\(videoId)/play_720p.mp4",
      token: token,
      expires: expires
    )
    let url360p = buildPlaybackUrl(
      baseUrl: "https://\(host)/\(videoId)/play_360p.mp4",
      token: token,
      expires: expires
    )
    let url720p = buildPlaybackUrl(
      baseUrl: "https://\(host)/\(videoId)/play_720p.mp4",
      token: token,
      expires: expires
    )
    let url1080p = buildPlaybackUrl(
      baseUrl: "https://\(host)/\(videoId)/play_1080p.mp4",
      token: token,
      expires: expires
    )

    let payload: [String: Any] = [
      "videoId": videoId,
      "libraryId": requestedLibraryId,
      "videoPlaylistUrl": playlistUrl,
      "fallbackUrl": fallbackUrl,
      "url360p": url360p,
      "url720p": url720p,
      "url1080p": url1080p,
    ]
    result(payload)
  }

  /// Adds optional tokenized query parameters to a playback URL.
  private func buildPlaybackUrl(baseUrl: String, token: String?, expires: Int?) -> String {
    let normalizedToken = token?.isEmpty == false ? token : nil
    if normalizedToken == nil, expires == nil {
      return baseUrl
    }

    guard var components = URLComponents(string: baseUrl) else {
      var result = baseUrl
      var hasQuery = baseUrl.contains("?")
      if let normalizedToken {
        result += hasQuery ? "&" : "?"
        result += "token=\(normalizedToken)"
        hasQuery = true
      }
      if let expires {
        result += hasQuery ? "&" : "?"
        result += "expires=\(expires)"
      }
      return result
    }

    var queryItems = components.queryItems ?? []
    if let normalizedToken {
      queryItems.append(URLQueryItem(name: "token", value: normalizedToken))
    }
    if let expires {
      queryItems.append(URLQueryItem(name: "expires", value: String(expires)))
    }
    components.queryItems = queryItems

    return components.url?.absoluteString ?? baseUrl
  }

  /// Fetches a single video metadata payload from Bunny management API.
  private func handleGetVideo(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let accessKey = accessKey, !accessKey.isEmpty else {
      result(
        FlutterError(
          code: "NOT_INITIALIZED", message: "Call initialize() before requesting video metadata.",
          details: nil))
      return
    }

    guard let args = call.arguments as? [String: Any] else {
      result(
        FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are required.", details: nil))
      return
    }

    let requestedLibraryId = args["libraryId"] as? Int
    let videoId = (args["videoId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)

    guard let requestedLibraryId, requestedLibraryId > 0 else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENT", message: "libraryId must be a positive integer.", details: nil))
      return
    }

    guard let videoId, !videoId.isEmpty else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "videoId is required.", details: nil))
      return
    }

    let urlString = "https://video.bunnycdn.com/library/\(requestedLibraryId)/videos/\(videoId)"
    guard let url = URL(string: urlString) else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid URL.", details: nil))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(accessKey, forHTTPHeaderField: "AccessKey")
    request.setValue("application/json", forHTTPHeaderField: "accept")
    request.timeoutInterval = 10

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        result(
          FlutterError(
            code: "NETWORK_ERROR", message: "Failed to fetch video: \(error.localizedDescription)",
            details: nil))
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        result(FlutterError(code: "NETWORK_ERROR", message: "Invalid response.", details: nil))
        return
      }

      guard httpResponse.statusCode == 200 else {
        let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
        result(
          FlutterError(
            code: "API_ERROR",
            message: "Bunny API returned \(httpResponse.statusCode): \(errorMessage)",
            details: nil))
        return
      }

      guard let data = data else {
        result(FlutterError(code: "API_ERROR", message: "No data received.", details: nil))
        return
      }

      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          result(json)
        } else {
          result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse JSON.", details: nil))
        }
      } catch {
        result(
          FlutterError(
            code: "PARSE_ERROR", message: "JSON parsing error: \(error.localizedDescription)",
            details: nil))
      }
    }

    task.resume()
  }

  /// Fetches videos for a library, optionally filtered by collection id.
  ///
  /// Returns an array extracted from `items` or `results` in API response.
  private func handleListVideos(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let accessKey = accessKey, !accessKey.isEmpty else {
      result(
        FlutterError(
          code: "NOT_INITIALIZED", message: "Call initialize() before requesting videos.",
          details: nil))
      return
    }

    guard let args = call.arguments as? [String: Any] else {
      result(
        FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are required.", details: nil))
      return
    }

    let requestedLibraryId = args["libraryId"] as? Int
    let collectionId = (args["collectionId"] as? String)?.trimmingCharacters(
      in: .whitespacesAndNewlines)

    guard let requestedLibraryId, requestedLibraryId > 0 else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENT", message: "libraryId must be a positive integer.", details: nil))
      return
    }

    var urlString = "https://video.bunnycdn.com/library/\(requestedLibraryId)/videos"
    if let collectionId = collectionId, !collectionId.isEmpty {
      urlString += "?collection=\(collectionId)"
    }

    guard let url = URL(string: urlString) else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid URL.", details: nil))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(accessKey, forHTTPHeaderField: "AccessKey")
    request.setValue("application/json", forHTTPHeaderField: "accept")
    request.timeoutInterval = 10

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        result(
          FlutterError(
            code: "NETWORK_ERROR", message: "Failed to fetch videos: \(error.localizedDescription)",
            details: nil))
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        result(FlutterError(code: "NETWORK_ERROR", message: "Invalid response.", details: nil))
        return
      }

      guard httpResponse.statusCode == 200 else {
        let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
        result(
          FlutterError(
            code: "API_ERROR",
            message: "Bunny API returned \(httpResponse.statusCode): \(errorMessage)",
            details: nil))
        return
      }

      guard let data = data else {
        result(FlutterError(code: "API_ERROR", message: "No data received.", details: nil))
        return
      }

      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          let itemsArray =
            json["items"] as? [[String: Any]] ?? json["results"] as? [[String: Any]] ?? []
          result(itemsArray)
        } else {
          result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse JSON.", details: nil))
        }
      } catch {
        result(
          FlutterError(
            code: "PARSE_ERROR", message: "JSON parsing error: \(error.localizedDescription)",
            details: nil))
      }
    }

    task.resume()
  }
}
