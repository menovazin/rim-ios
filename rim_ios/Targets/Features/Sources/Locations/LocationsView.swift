import ComposableArchitecture
import DesignSystem
import Models
import SwiftUI

/// Paginated Locations list matching `locations_page.dart`.
///
/// Vertical `LazyVStack` of location tiles with infinite scroll (300pt sentinel)
/// and full-screen / footer loading/error states.
public struct LocationsView: View {
    @Bindable public var store: StoreOf<LocationsReducer>
    @Environment(\.rimTheme) private var theme

    public init(store: StoreOf<LocationsReducer>) {
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

    // MARK: - Error (full-screen) — Flutter GridErrorTile + padding 24

    @ViewBuilder
    private var errorView: some View {
        VStack {
            Spacer()
            RimGridErrorTile(onRetry: { store.send(.retry) })
                .padding(RimSpacing.huge)
            Spacer()
        }
    }

    // MARK: - List

    @ViewBuilder
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: RimSpacing.md) {
                ForEach(store.items) { location in
                    LocationTile(location: location)
                        .onTapGesture {
                            store.send(.cardTapped(location))
                        }
                }

                // Pagination footer
                if store.isLoadingMore {
                    ProgressView()
                        .tint(theme.colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, RimSpacing.xxxl)
                } else if store.loadMoreFailed {
                    RimGridErrorTile(onRetry: { store.send(.retry) })
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

// MARK: - Location tile

/// A single location row matching Flutter `_LocationTile`.
///
/// `RoundedRectangle(cornerRadius: 12)` `surface` fill, leading 48pt
/// circle (`secondary @ 18%`) with Material type icon (`secondary`),
/// title + subtitle, trailing `chevron_right`.
struct LocationTile: View {
    let location: Location
    @Environment(\.rimTheme) private var theme

    var body: some View {
        HStack(spacing: RimSpacing.lg) {
            // Leading icon circle — Material Icons via location_type_x mapping
            Circle()
                .fill(theme.colors.secondary.opacity(0.18))
                .frame(width: 48, height: 48)
                .overlay(
                    RimIcon(
                        RimIconName.locationType(location.type),
                        size: 20,
                        color: theme.colors.secondary
                    )
                )

            // Text column
            VStack(alignment: .leading, spacing: RimSpacing.xxs) {
                Text(location.name)
                    .rimTextStyle(RimTypography.titleSmall)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text("\(location.type.isEmpty ? "Unknown" : location.type) • \(location.dimension.isEmpty ? "Unknown" : location.dimension)")
                    .rimTextStyle(RimTypography.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer()

            RimIcon(.chevronRight, size: 24, color: theme.colors.textSecondary)
        }
        .padding(.horizontal, RimSpacing.xxl)
        .padding(.vertical, RimSpacing.xl)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: RimRadius.card))
    }
}

// MARK: - Previews

#Preview("Dark — Loaded") {
    let locations = (1...10).map { i in
        Location(
            id: i,
            name: "Location \(i)",
            type: i % 2 == 0 ? "Planet" : "Space Station",
            dimension: "Dimension C-\(i)",
            residentIds: Array(1...i)
        )
    }
    LocationsView(
        store: Store(
            initialState: LocationsReducer.State(
                items: .init(uniqueElements: locations)
            )
        ) {
            LocationsReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light — Loaded") {
    let locations = (1...5).map { i in
        Location(
            id: i, name: "Earth (\(i))", type: "Planet",
            dimension: "Dimension C-137", residentIds: [1, 2]
        )
    }
    LocationsView(
        store: Store(
            initialState: LocationsReducer.State(
                items: .init(uniqueElements: locations)
            )
        ) {
            LocationsReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .light))
}

#Preview("Dark — Loading") {
    LocationsView(
        store: Store(
            initialState: LocationsReducer.State(isLoadingInitial: true)
        ) {
            LocationsReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Dark — Error") {
    LocationsView(
        store: Store(
            initialState: LocationsReducer.State(loadFailed: true)
        ) {
            LocationsReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
}
