import ComposableArchitecture
import DesignSystem
import Models
import SwiftUI

/// Paginated Episodes list matching `episodes_page.dart`.
///
/// Vertical `LazyVStack` of episode tiles with infinite scroll (300pt sentinel)
/// and full-screen / footer loading/error states.
public struct EpisodesView: View {
    @Bindable public var store: StoreOf<EpisodesReducer>
    @Environment(\.rimTheme) private var theme

    public init(store: StoreOf<EpisodesReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()

            if store.isLoadingInitial && store.items.isEmpty {
                loadingView
            } else if store.loadFailed && store.items.isEmpty {
                errorView
            } else {
                listView
            }
        }
        .onAppear { store.send(.onAppear) }
    }

    // MARK: - Loading (full-screen)

    @ViewBuilder
    private var loadingView: some View {
        VStack {

            Spacer()
            ProgressView()
                .tint(theme.colors.primary)
            Spacer()
        }
    }

    // MARK: - Error (full-screen)

    @ViewBuilder
    private var errorView: some View {
        VStack {
            Spacer()
            Button {
                store.send(.retry)
            } label: {
                VStack(spacing: RimSpacing.sm) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                    Text("Retry")
                        .rimTextStyle(RimTypography.labelLarge)
                }
                .foregroundStyle(theme.colors.primary)
            }
            Spacer()
        }
    }

    // MARK: - List

    @ViewBuilder
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: RimSpacing.md) {
                ForEach(store.items) { episode in
                    EpisodeTile(episode: episode)
                        .onTapGesture {
                            store.send(.cardTapped(episode))
                        }
                }

                // Pagination footer
                if store.isLoadingMore {
                    ProgressView()
                        .tint(theme.colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, RimSpacing.xxxl)
                } else if store.loadMoreFailed {
                    Button {
                        store.send(.retry)
                    } label: {
                        VStack(spacing: RimSpacing.xxs) {
                            Image(systemName: "arrow.clockwise")
                            Text("Retry")
                                .rimTextStyle(RimTypography.labelMedium)
                        }
                        .foregroundStyle(theme.colors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(RimSpacing.xxl)
                }

                // Sentinel for infinite scroll (300pt threshold)
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        store.send(.loadMore)
                    }
            }
            .padding(RimSpacing.lg)
        }
    }
}

// MARK: - Episode tile

/// A single episode row matching Flutter `_EpisodeTile`.
///
/// `RoundedRectangle(cornerRadius: 12)` `surface` fill, leading 48×48
/// icon container (`primary @ 12%`, `12pt` radius) with `S##`/`E##`,
/// title + subtitle, trailing chevron.
struct EpisodeTile: View {
    let episode: Episode
    @Environment(\.rimTheme) private var theme

    var body: some View {
        HStack(spacing: RimSpacing.lg) {
            // Leading icon container
            iconContainer

            // Text column
            VStack(alignment: .leading, spacing: RimSpacing.xxs) {
                Text(episode.name)
                    .rimTextStyle(RimTypography.titleSmall)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(episode.airDate)
                    .rimTextStyle(RimTypography.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()

            // Trailing chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.horizontal, RimSpacing.xxl)
        .padding(.vertical, RimSpacing.xl)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: RimRadius.card))
    }

    @ViewBuilder
    private var iconContainer: some View {
        let code = episode.parsedCode
        VStack(spacing: 2) {
            Text("S\(String(format: "%02d", code.season))")
                .rimTextStyle(RimTypography.labelSmall)
                .fontWeight(.bold)
                .foregroundStyle(theme.colors.primary)

            Text("E\(String(format: "%02d", code.episodeNumber))")
                .rimTextStyle(RimTypography.labelSmall)
                .fontWeight(.semibold)
                .font(.system(size: 10))
                .foregroundStyle(theme.colors.primary.opacity(0.6))
        }
        .frame(width: 48, height: 48)
        .background(theme.colors.primary.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: RimRadius.card))
    }
}

// MARK: - Previews

#Preview("Dark — Loaded") {
    let episodes = (1...10).map { i in
        Episode(
            id: i,
            name: "Episode \(i)",
            episodeCode: "S\(String(format: "%02d", i / 3 + 1))E\(String(format: "%02d", i % 3 + 1))",
            airDate: "December 2, 2013",
            characterIds: [1, 2, 3]
        )
    }
    EpisodesView(
        store: Store(
            initialState: EpisodesReducer.State(
                items: .init(uniqueElements: episodes)
            )
        ) {
            EpisodesReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light — Loaded") {
    let episodes = (1...5).map { i in
        Episode(
            id: i,
            name: "Episode \(i)",
            episodeCode: "S01E\(String(format: "%02d", i))",
            airDate: "December 2, 2013",
            characterIds: [1]
        )
    }
    EpisodesView(
        store: Store(
            initialState: EpisodesReducer.State(
                items: .init(uniqueElements: episodes)
            )
        ) {
            EpisodesReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .light))
}

#Preview("Dark — Loading") {
    EpisodesView(
        store: Store(
            initialState: EpisodesReducer.State(isLoadingInitial: true)
        ) {
            EpisodesReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Dark — Error") {
    EpisodesView(
        store: Store(
            initialState: EpisodesReducer.State(loadFailed: true)
        ) {
            EpisodesReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}
