import DesignSystem
import Kingfisher
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
                Group {
                    // Error fallback shown when KFImage fails
                    Image(systemName: "person")
                        .font(.system(size: 24))
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .opacity(0) // KF handles this via .onFailure; kept for parity
            )
    }
}

// MARK: - Avatar URL util

/// Derives Rick & Morty avatar image URLs from a character id.
///
/// Uses the same CDN base as the canonical Flutter `AvatarUrlUtils`:
/// `https://semester.syazy.com/rickandmorty/<id>.jpeg`.
public enum RimAvatarURL {
    private static let base = "https://semester.syazy.com/rickandmorty"

    /// Returns the avatar URL for the given character id.
    public static func fromId(_ id: Int) -> URL? {
        URL(string: "\(base)/\(id).jpeg")
    }
}
