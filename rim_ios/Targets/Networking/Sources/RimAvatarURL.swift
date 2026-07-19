import Foundation

/// Derives Rick & Morty avatar image URLs.
///
/// Mirrors the canonical Flutter `AvatarUrlUtils`:
/// - `avatarUrlFromId` → `fromId(_:)` — build avatar URL from a character id
/// - `getCustomAvatarUrl` → `fixing(_:)` — prepend API base to relative URLs
public enum RimAvatarURL {
    /// Returns the avatar URL for the given character id.
    public static func fromId(_ id: Int) -> URL? {
        URL(string: "\(ApiConstants.characterEndpoint)/avatar/\(id).jpeg")
    }

    /// Fixes a possibly-relative avatar URL returned by the API.
    /// If `originalUrl` is relative (starts with `/`), prepends `ApiConstants.baseUrl`;
    /// otherwise returns `originalUrl` unchanged.
    public static func fixing(_ originalUrl: String) -> String {
        originalUrl.hasPrefix("/") ? "\(ApiConstants.baseUrl)\(originalUrl)" : originalUrl
    }
}
