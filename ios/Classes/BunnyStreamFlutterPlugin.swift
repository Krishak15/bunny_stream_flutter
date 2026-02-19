import Flutter
import UIKit

public class BunnyStreamFlutterPlugin: NSObject, FlutterPlugin {
  private var accessKey: String?
  private var libraryId: Int?
  private var cdnHostname: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "bunny_stream_flutter", binaryMessenger: registrar.messenger())
    let instance = BunnyStreamFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      handleInitialize(call, result: result)
    case "listVideos", "getVideo", "listCollections", "getCollection":
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
    let payload: [String: Any] = [
      "videoId": videoId,
      "libraryId": requestedLibraryId,
      "videoPlaylistUrl": "https://\(host)/\(videoId)/playlist.m3u8",
      "fallbackUrl": "https://\(host)/\(videoId)/play_720p.mp4",
    ]
    result(payload)
  }
}
