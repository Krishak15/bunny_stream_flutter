import BunnyStreamPlayer
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
        let playIconAsset = params?["playIconAsset"] as? String ?? ""
        let token = params?["token"] as? String
        let expires =
            (params?["expires"] as? Int64)
            ?? (params?["expires"] as? Int).map(Int64.init)

        let controller = BunnyPlayerViewController(
            accessKey: accessKey,
            videoId: videoId,
            libraryId: libraryId,
            playIconAsset: playIconAsset,
            token: token,
            expires: expires,
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
    let playIconAsset: String
    let token: String?
    let expires: Int64?

    init(
        accessKey: String?,
        videoId: String,
        libraryId: Int,
        playIconAsset: String,
        token: String?,
        expires: Int64?,
    ) {
        self.accessKey = accessKey
        self.videoId = videoId
        self.libraryId = libraryId
        self.playIconAsset = playIconAsset
        self.token = token
        self.expires = expires
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        #if canImport(BunnyStreamPlayer)
            let iconImage = loadFlutterAsset(named: playIconAsset)
            let icons = PlayerIcons(play: iconImage)
            let playerView = BunnyFlutterPlayer(
                accessKey: accessKey,
                videoId: videoId,
                libraryId: libraryId,
                playerIcons: icons,
                token: token,
                expires: expires
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
                "Bunny iOS native player dependency is unavailable. Swift Package Manager may be enabled, but Bunny iOS package is not linked. Add https://github.com/BunnyWay/bunny-stream-ios in Xcode (Runner > Package Dependencies) and select BunnyStreamPlayer."
            view.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        #endif
    }

    private func loadFlutterAsset(named asset: String) -> Image {
        guard !asset.isEmpty else {
            return Image(systemName: "play.fill")
        }

        let key = FlutterDartProject.lookupKey(forAsset: asset)
        if let path = Bundle.main.path(forResource: key, ofType: nil),
            let uiImage = UIImage(contentsOfFile: path)
        {
            return Image(uiImage: uiImage)
        }

        return Image(systemName: "play.fill")
    }
}

#if canImport(BunnyStreamPlayer)
    import BunnyStreamPlayer

    struct BunnyFlutterPlayer: View {
        let accessKey: String?
        let videoId: String
        let libraryId: Int
        let playerIcons: PlayerIcons
        let token: String?
        let expires: Int64?

        var body: some View {
            BunnyStreamPlayer(
                accessKey: accessKey,
                videoId: videoId,
                libraryId: libraryId,
                token: token,
                expires: expires,
                playerIcons: playerIcons,
            )
        }
    }
#endif
