import ComposableArchitecture
import DesignSystem
import Kingfisher
import Models
import SwiftUI

/// Episode Detail screen matching `episode_detail_page.dart`.
///
/// Receives the `Episode` from the list, renders it immediately, and derives
/// resident avatars from `episode.characterIds` — no fetch.
public struct EpisodeDetailView: View {
    @Bindable public var store: StoreOf<EpisodeDetailReducer>
    @Environment(\.rimTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<EpisodeDetailReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            RimAppBar(
                title: store.episode.name,
                leading: .back({ dismiss() })
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroCard

                    charactersSection
                        .padding(.top, RimSpacing.huge)
                }
                .padding(RimSpacing.xxl)
            }
        }
        .background(theme.colors.background)
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Gradient hero card

    @ViewBuilder
    private var heroCard: some View {
        let code = store.episode.parsedCode

        VStack(alignment: .leading, spacing: 0) {
            // Badge row
            HStack(spacing: RimSpacing.sm) {
                // S## filled badge
                Text("S\(String(format: "%02d", code.season))")
                    .rimTextStyle(RimTypography.labelLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.onPrimary)
                    .padding(.horizontal, RimSpacing.md)
                    .padding(.vertical, RimSpacing.xxs)
                    .background(theme.colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: RimRadius.small))

                // E## outlined badge
                Text("E\(String(format: "%02d", code.episodeNumber))")
                    .rimTextStyle(RimTypography.labelLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.primary)
                    .padding(.horizontal, RimSpacing.md)
                    .padding(.vertical, RimSpacing.xxs)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: RimRadius.small)
                            .stroke(theme.colors.primary.opacity(0.4), lineWidth: 1)
                    )
            }

            // Name
            Text(store.episode.name)
                .rimTextStyle(RimTypography.headlineSmall)
                .fontWeight(.bold)
                .foregroundStyle(theme.colors.textPrimary)
                .padding(.top, RimSpacing.lg)

            // Air date
            Text(store.episode.airDate)
                .rimTextStyle(RimTypography.bodyMedium)
                .foregroundStyle(theme.colors.textSecondary)
                .padding(.top, RimSpacing.xxs)
        }
        .padding(RimSpacing.xxxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RimDetailGradient.linear(
                accent: theme.colors.primary,
                surface: theme.colors.surface,
                background: theme.colors.background
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: RimRadius.image))
    }

    // MARK: - Characters section

    @ViewBuilder
    private var charactersSection: some View {
        DetailSectionTitle(title: "Characters (\(store.episode.characterIds.count))")

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: RimSpacing.sm) {
                ForEach(store.episode.characterIds, id: \.self) { id in
                    CharacterAvatarCircle(
                        characterId: id,
                        name: "#\(id)"
                    )
                }
            }
        }
        .frame(height: 72)
        .padding(.top, RimSpacing.lg)
    }
}

// MARK: - Previews

#Preview("Dark — Loaded") {
    NavigationStack {
        EpisodeDetailView(
            store: Store(
                initialState: EpisodeDetailReducer.State(
                    episode: Episode(
                        id: 1,
                        name: "Pilot",
                        episodeCode: "S01E01",
                        airDate: "December 2, 2013",
                        characterIds: [1, 2, 3, 4, 5]
                    )
                )
            ) {
                EpisodeDetailReducer()
            }
        )
    }
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light — Loaded") {
    NavigationStack {
        EpisodeDetailView(
            store: Store(
                initialState: EpisodeDetailReducer.State(
                    episode: Episode(
                        id: 2,
                        name: "Lawnmower Dog",
                        episodeCode: "S01E02",
                        airDate: "December 9, 2013",
                        characterIds: [1, 2]
                    )
                )
            ) {
                EpisodeDetailReducer()
            }
        )
    }
    .rimTheme(RimTheme(scheme: .light))
}
