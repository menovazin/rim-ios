import ComposableArchitecture
import DesignSystem
import Models
import SwiftUI

/// Location Detail screen matching `location_detail_page.dart`.
///
/// Receives the `Location` from the list, renders it immediately, and derives
/// resident avatars from `location.residentIds` — no fetch.
public struct LocationDetailView: View {
    @Bindable public var store: StoreOf<LocationDetailReducer>
    @Environment(\.rimTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<LocationDetailReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            RimAppBar(
                title: store.location.name,
                leading: .back({ dismiss() })
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroCard

                    residentsSection
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
        let locType = store.location.type.isEmpty ? "Unknown" : store.location.type
        let dim = store.location.dimension.isEmpty ? "Unknown" : store.location.dimension

        VStack(alignment: .leading, spacing: 0) {
            // Type icon — Material Icons (Flutter location detail)
            RimIcon(
                RimIconName.locationType(store.location.type),
                size: 40,
                color: theme.colors.secondary
            )
            .padding(.top, RimSpacing.xxs)

            // Name
            Text(store.location.name)
                .rimTextStyle(RimTypography.headlineSmall)
                .fontWeight(.bold)
                .foregroundStyle(theme.colors.textPrimary)
                .padding(.top, RimSpacing.lg)

            // Badge row
            HStack(spacing: RimSpacing.sm) {
                // Type badge (filled, secondary)
                Text(locType)
                    .rimTextStyle(RimTypography.labelMedium)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.onSecondary)
                    .padding(.horizontal, RimSpacing.md)
                    .padding(.vertical, RimSpacing.xxs)
                    .background(theme.colors.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: RimRadius.small))

                // Dimension badge (outlined, secondary @ 40%)
                Text(dim)
                    .rimTextStyle(RimTypography.labelMedium)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.secondary)
                    .padding(.horizontal, RimSpacing.md)
                    .padding(.vertical, RimSpacing.xxs)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: RimRadius.small)
                            .stroke(theme.colors.secondary.opacity(0.4), lineWidth: 1)
                    )
            }
            .padding(.top, RimSpacing.sm)
        }
        .padding(RimSpacing.xxxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RimDetailGradient.linear(
                accent: theme.colors.secondary,
                surface: theme.colors.surface,
                background: theme.colors.background
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: RimRadius.image))
    }

    // MARK: - Residents section

    @ViewBuilder
    private var residentsSection: some View {
        DetailSectionTitle(title: "Residents (\(store.location.residentIds.count))")

        if store.location.residentIds.isEmpty {
            Text("No residents")
                .rimTextStyle(RimTypography.bodyMedium)
                .foregroundStyle(theme.colors.textSecondary)
                .padding(.top, RimSpacing.lg)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: RimSpacing.sm) {
                    ForEach(store.location.residentIds, id: \.self) { id in
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
}

// MARK: - Previews

#Preview("Dark — Loaded") {
    NavigationStack {
        LocationDetailView(
            store: Store(
                initialState: LocationDetailReducer.State(
                    location: Location(
                        id: 1,
                        name: "Earth (C-137)",
                        type: "Planet",
                        dimension: "Dimension C-137",
                        residentIds: [1, 2, 3, 4, 5]
                    )
                )
            ) {
                LocationDetailReducer()
            }
        )
    }
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light — Loaded") {
    NavigationStack {
        LocationDetailView(
            store: Store(
                initialState: LocationDetailReducer.State(
                    location: Location(
                        id: 2,
                        name: "Citadel of Ricks",
                        type: "Space Station",
                        dimension: "unknown",
                        residentIds: [1, 2]
                    )
                )
            ) {
                LocationDetailReducer()
            }
        )
    }
    .rimTheme(RimTheme(scheme: .light))
}

#Preview("Dark — No Residents") {
    NavigationStack {
        LocationDetailView(
            store: Store(
                initialState: LocationDetailReducer.State(
                    location: Location(
                        id: 3,
                        name: "Anatomy Park",
                        type: "Microverse",
                        dimension: "Dimension C-137",
                        residentIds: []
                    )
                )
            ) {
                LocationDetailReducer()
            }
        )
    }
    .rimTheme(RimTheme(scheme: .dark))
}
