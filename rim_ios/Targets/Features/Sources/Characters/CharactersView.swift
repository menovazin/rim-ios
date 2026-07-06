import ComposableArchitecture
import DesignSystem
import Models
import Networking
import SwiftUI

/// Paginated Characters grid matching `characters_page.dart` and `DESIGN_SYSTEM.md §4`.
///
/// Adaptive `LazyVGrid` with `(width / 200).clamped(1...6)` columns,
/// 12pt spacing/padding, 0.72 aspect ratio cards.
///
/// Navigation is owned by the Shell; this view emits `cardTapped` and does not
/// contain a `NavigationStack`.
public struct CharactersView: View {
    @Bindable public var store: StoreOf<CharactersReducer>
    @Environment(\.rimTheme) private var theme

    public init(store: StoreOf<CharactersReducer>) {
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
                gridView
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

    // MARK: - Grid

    @ViewBuilder
    private var gridView: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let columns = max(1, min(6, Int(width / 200)))
            let gridItems = Array(
                repeating: GridItem(.flexible(), spacing: RimSpacing.lg),
                count: columns
            )

            ScrollView {
                LazyVGrid(columns: gridItems, spacing: RimSpacing.lg) {
                    ForEach(store.items) { character in
                        CharacterCard(character: character)
                            .aspectRatio(0.72, contentMode: .fit)
                            .padding(_: 4)
                            .onTapGesture {
                                store.send(.cardTapped(character))
                            }
                    }

                    // Pagination footer (matches Flutter: loading 20pt vertical, error 16pt all)
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
}

// MARK: - Previews

#Preview("Dark — Loaded") {
    let chars = (1...20).map { i in
        Character(
            id: i, name: "Character \(i)", status: i % 3 == 0 ? "Dead" : "Alive",
            species: "Human", type: "", gender: "Male",
            image: "\(ApiConstants.characterEndpoint)/avatar/\(i).jpeg",
            originName: "Earth", originUrl: "", locationName: "Earth", locationUrl: "",
            episodeIds: [1]
        )
    }
    CharactersView(
        store: Store(
            initialState: CharactersReducer.State(
                items: .init(uniqueElements: chars)
            )
        ) {
            CharactersReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light — Loaded") {
    let chars = (1...6).map { i in
        Character(
            id: i, name: "Character \(i)", status: "Alive",
            species: "Human", type: "", gender: "Male",
            image: "\(ApiConstants.characterEndpoint)/avatar/\(i).jpeg",
            originName: "Earth", originUrl: "", locationName: "Earth", locationUrl: "",
            episodeIds: [1]
        )
    }
    CharactersView(
        store: Store(
            initialState: CharactersReducer.State(
                items: .init(uniqueElements: chars)
            )
        ) {
            CharactersReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .light))
}

#Preview("Dark — Loading") {
    CharactersView(
        store: Store(
            initialState: CharactersReducer.State(isLoadingInitial: true)
        ) {
            CharactersReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Dark — Error") {
    CharactersView(
        store: Store(
            initialState: CharactersReducer.State(loadFailed: true)
        ) {
            CharactersReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}
