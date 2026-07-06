import Foundation

/// Mirror of the canonical Flutter `ApiConstants`
/// (`lib/api/constants/api_constants.dart`).
///
/// Single source of truth for the API host and derived URLs/endpoints.
public enum ApiConstants {
    public static let host = "alpha.syazy.com"
    public static let baseUrl = "https://\(host)/api"

    public static let characterEndpoint = "\(baseUrl)/character"
    public static let episodeEndpoint = "\(baseUrl)/episode"
    public static let locationEndpoint = "\(baseUrl)/location"

    public static let characterPath = "/character"
    public static let episodePath = "/episode"
    public static let locationPath = "/location"
}