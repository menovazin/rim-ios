import ComposableArchitecture
import DesignSystem
import Kingfisher
import Models
import Networking
import SwiftUI

/// Character Detail screen matching `DESIGN_SYSTEM.md §5` and the canonical
/// Flutter `character_detail_page.dart`.
///
/// Receives the `Character` from the grid, renders it immediately, and derives
/// episode chips from `character.episodeIds` — no fetch.
public struct CharacterDetailView: View {
    @Bindable public var store: StoreOf<CharacterDetailReducer>
    @Environment(\.rimTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<CharacterDetailReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            RimAppBar(
                title: store.character.name,
                leading: .back({ dismiss() })
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage

                    statusRow
                        .padding(.top, RimSpacing.xxl)

                    infoRows
                        .padding(.top, RimSpacing.xxl)

                    episodesSection
                        .padding(.top, RimSpacing.xxl)
                }
                .padding(RimSpacing.xxl)
            }
        }
        .background(theme.colors.background)
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Hero image

    @ViewBuilder
    private var heroImage: some View {
        KFImage(URL(string: store.character.image))
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
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: RimRadius.image))
            .overlay(
                RoundedRectangle(cornerRadius: RimRadius.image)
                    .fill(theme.colors.surface.opacity(0))
            )
    }

    // MARK: - Status row

    @ViewBuilder
    private var statusRow: some View {
        HStack(spacing: RimSpacing.sm) {
            Circle()
                .fill(store.character.statusColor)
                .frame(width: 12, height: 12)

            Text(store.character.statusAndSpecies)
                .rimTextStyle(RimTypography.titleMedium)
                .foregroundStyle(theme.colors.textPrimary)
        }
    }

    // MARK: - Info rows

    @ViewBuilder
    private var infoRows: some View {
        VStack(spacing: 0) {
            DetailInfoRow(label: "Species", value: store.character.species)

            if !store.character.type.isEmpty {
                DetailInfoRow(label: "Type", value: store.character.type)
            }

            DetailInfoRow(label: "Gender", value: store.character.detailGender)
            DetailInfoRow(label: "Origin", value: store.character.originName)
            DetailInfoRow(label: "Location", value: store.character.locationName)
        }
    }

    // MARK: - Episodes section

    @ViewBuilder
    private var episodesSection: some View {
        DetailSectionTitle(title: "Episodes (\(store.character.episodeIds.count))")

        FlowLayout(
            spacing: RimDetailTokens.chipSpacing,
            runSpacing: RimDetailTokens.chipRunSpacing
        ) {
            ForEach(store.character.episodeIds, id: \.self) { id in
                DetailChip(label: "E\(String(format: "%02d", id))")
            }
        }
        .padding(.top, RimSpacing.sm)
    }
}

// MARK: - Previews

#Preview("Dark — Loaded") {
    NavigationStack {
        CharacterDetailView(
            store: Store(
                initialState: CharacterDetailReducer.State(
                    character: Character(
                        id: 1, name: "Rick Sanchez", status: "Alive", species: "Human",
                        type: "", gender: "Male",
                        image: "\(ApiConstants.characterEndpoint)/avatar/1.jpeg",
                        originName: "Earth (C-137)", originUrl: "",
                        locationName: "Citadel of Ricks", locationUrl: "",
                        episodeIds: [1, 2, 3, 42]
                    )
                )
            ) {
                CharacterDetailReducer()
            }
        )
    }
    .rimTheme(RimTheme(scheme: .dark))
}

#Preview("Light — Loaded") {
    NavigationStack {
        CharacterDetailView(
            store: Store(
                initialState: CharacterDetailReducer.State(
                    character: Character(
                        id: 2, name: "Morty Smith", status: "Alive", species: "Human",
                        type: "", gender: "Male",
                        image: "\(ApiConstants.characterEndpoint)/avatar/2.jpeg",
                        originName: "Earth (C-137)", originUrl: "",
                        locationName: "Earth (Replacement Dimension)", locationUrl: "",
                        episodeIds: [1, 2]
                    )
                )
            ) {
                CharacterDetailReducer()
            }
        )
    }
    .rimTheme(RimTheme(scheme: .light))
}
