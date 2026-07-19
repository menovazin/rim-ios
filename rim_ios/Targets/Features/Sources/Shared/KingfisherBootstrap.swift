import Foundation
import Kingfisher

/// Global Kingfisher startup configuration.
///
/// Call once at app launch, before any `KFImage` appears.
public enum KingfisherBootstrap {
    /// Caps concurrent remote image downloads app-wide (per host).
    ///
    /// Kingfisher 8 has no `maxConcurrentDownloads` on `ImageDownloader`;
    /// concurrency is controlled via `URLSessionConfiguration`.
    /// All avatar/image URLs share one API host, so this is a global cap of 4.
    public static func configure() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpMaximumConnectionsPerHost = 4
        ImageDownloader.default.sessionConfiguration = configuration
    }
}
