import Flutter
import SwiftUI
import UIKit

class BunnyPlayerPlatformView: NSObject, FlutterPlatformView {
    private let playerView: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger?
    ) {
        let params = args as? [String: Any]
        let accessKey = params?["accessKey"] as? String
        let videoId = (params?["videoId"] as? String ?? "").trimmingCharacters(
            in: .whitespacesAndNewlines)
        let libraryId = params?["libraryId"] as? Int ?? 0
        let token = params?["token"] as? String
        let expires = params?["expires"] as? Int
        let referer = params?["referer"] as? String

        let controller = BunnyPlayerViewController(
            accessKey: accessKey,
            videoId: videoId,
            libraryId: libraryId,
            token: token,
            expires: expires,
            referer: referer
        )
        playerView = controller.view
        super.init()
    }

    func view() -> UIView {
        return playerView
    }
}

public class BunnyPlayerPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return BunnyPlayerPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            messenger: messenger
        )
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class BunnyPlayerViewController: UIViewController {
    let accessKey: String?
    let videoId: String
    let libraryId: Int
    let token: String?
    let expires: Int?
    let referer: String?

    init(
        accessKey: String?,
        videoId: String,
        libraryId: Int,
        token: String?,
        expires: Int?,
        referer: String?
    ) {
        self.accessKey = accessKey
        self.videoId = videoId
        self.libraryId = libraryId
        self.token = token
        self.expires = expires
        self.referer = referer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        #if canImport(BunnyStreamPlayer)
            let playerView = BunnyFlutterPlayer(
                accessKey: accessKey,
                videoId: videoId,
                libraryId: libraryId,
                token: token,
                expires: expires,
                referer: referer
            )
            let hostingController = UIHostingController(rootView: playerView)
            addChild(hostingController)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)

            NSLayoutConstraint.activate([
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        #else
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text =
                "Bunny iOS native player dependency is unavailable. Enable Swift Package Manager and sync iOS dependencies."
            view.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        #endif
    }
}

#if canImport(BunnyStreamPlayer)
    import BunnyStreamPlayer

    struct BunnyFlutterPlayer: View {
        let accessKey: String?
        let videoId: String
        let libraryId: Int
        let token: String?
        let expires: Int?
        let referer: String?

        var body: some View {
            BunnyStreamPlayer(
                accessKey: accessKey,
                videoId: videoId,
                libraryId: libraryId,
                token: token,
                expires: expires,
                referer: referer
            )
        }
    }
#endif
