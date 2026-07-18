import DesignSystem
import Kingfisher
import Networking
import SwiftUI

/// Circular character avatar (48×48) with optional name label below.
///
/// Derives its image URL from the character id via `RimAvatarURL.fromId(_:)`,
/// matching Flutter `character_avatar_circle.dart` `AvatarUrlUtils.avatarUrlFromId`.
public struct CharacterAvatarCircle: View {
    let characterId: Int
    let name: String?

    @Environment(\.rimTheme) private var theme

    public init(characterId: Int, name: String? = nil) {
        self.characterId = characterId
        self.name = name
    }

    public var body: some View {
        if let name, !name.isEmpty {
            VStack(spacing: RimSpacing.xxs) {
                avatarCircle
                Text(name)
                    .rimTextStyle(RimTypography.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 64)
            }
        } else {
            avatarCircle
        }
    }

    @ViewBuilder
    private var avatarCircle: some View {
        KFImage(RimAvatarURL.fromId(characterId))
            .placeholder {
                ZStack {
                    theme.colors.surface
                    ProgressView()
                        .tint(theme.colors.primary)
                }
            }
            .onFailure { _ in }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.clear, lineWidth: 0)
            )
            .background(
                Circle().fill(theme.colors.surface)
            )
            .overlay(
                // Flutter avatar fallback: Icons.person size 24
                RimIcon(.person, size: 24, color: theme.colors.textSecondary)
                    .opacity(0) // KF handles failure; kept for parity reference
            )
    }
}

// MARK: - Avatar URL util

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
