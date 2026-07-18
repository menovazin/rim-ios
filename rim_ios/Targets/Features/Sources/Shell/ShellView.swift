import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ShellView: View {
    @Bindable var store: StoreOf<ShellReducer>
    @Environment(\.rimTheme) private var theme
    @Environment(RimThemeController.self) private var themeController
    @State private var mountedTabs: Set<ShellTab> = [.characters]

    public init(store: StoreOf<ShellReducer>) {
        self.store = store
    }

    public var body: some View {
        let isDrawerOpen = Binding<Bool>(
            get: { store.isDrawerOpen },
            set: { store.send(.setDrawerOpen($0)) }
        )

        return RimDrawer(isOpen: isDrawerOpen) {
            drawerMenu
        } content: {
            activeTabView
        }
        .onChange(of: store.selectedTab) { _, tab in
            mountedTabs.insert(tab)
        }
    }

    // MARK: - Active tab (keep-alive)

    @ViewBuilder
    private var activeTabView: some View {
        ZStack {
            if mountedTabs.contains(.characters) {
                charactersTab
                    .opacity(store.selectedTab == .characters ? 1 : 0)
                    .allowsHitTesting(store.selectedTab == .characters)
                    .accessibilityHidden(store.selectedTab != .characters)
            }

            if mountedTabs.contains(.episodes) {
                episodesTab
                    .opacity(store.selectedTab == .episodes ? 1 : 0)
                    .allowsHitTesting(store.selectedTab == .episodes)
                    .accessibilityHidden(store.selectedTab != .episodes)
            }

            if mountedTabs.contains(.locations) {
                locationsTab
                    .opacity(store.selectedTab == .locations ? 1 : 0)
                    .allowsHitTesting(store.selectedTab == .locations)
                    .accessibilityHidden(store.selectedTab != .locations)
            }
        }
    }

    // MARK: - Characters tab

    @ViewBuilder
    private var charactersTab: some View {
        NavigationStack(
            path: $store.scope(state: \.charactersPath, action: \.charactersPath)
        ) {
            VStack(spacing: 0) {
                RimAppBar(
                    title: ShellTab.characters.title,
                    leading: .menu({ store.send(.drawerOpenTapped) })
                )

                CharactersView(
                    store: store.scope(state: \.characters, action: \.characters)
                )
            }
            .toolbar(.hidden, for: .navigationBar)
        } destination: { store in
            switch store.case {
            case .characterDetail(let characterStore):
                CharacterDetailView(store: characterStore)
            }
        }
    }

    // MARK: - Episodes tab

    @ViewBuilder
    private var episodesTab: some View {
        NavigationStack(
            path: $store.scope(state: \.episodesPath, action: \.episodesPath)
        ) {
            VStack(spacing: 0) {
                RimAppBar(
                    title: ShellTab.episodes.title,
                    leading: .menu({ store.send(.drawerOpenTapped) })
                )

                EpisodesView(
                    store: store.scope(state: \.episodes, action: \.episodes)
                )
            }
            .toolbar(.hidden, for: .navigationBar)
        } destination: { store in
            switch store.case {
            case .episodeDetail(let episodeStore):
                EpisodeDetailView(store: episodeStore)
            }
        }
    }

    // MARK: - Locations tab

    @ViewBuilder
    private var locationsTab: some View {
        NavigationStack(
            path: $store.scope(state: \.locationsPath, action: \.locationsPath)
        ) {
            VStack(spacing: 0) {
                RimAppBar(
                    title: ShellTab.locations.title,
                    leading: .menu({ store.send(.drawerOpenTapped) })
                )

                LocationsView(
                    store: store.scope(state: \.locations, action: \.locations)
                )
            }
            .toolbar(.hidden, for: .navigationBar)
        } destination: { store in
            switch store.case {
            case .locationDetail(let locationStore):
                LocationDetailView(store: locationStore)
            }
        }
    }

    // MARK: - Drawer menu

    @ViewBuilder
    private var drawerMenu: some View {
        ZStack {
            VStack(spacing: 0) {
                drawerHeader

                Divider()
                    .background(theme.colors.textSecondary.opacity(0.15))
                    .padding(.horizontal, RimSpacing.xxl)
                    .padding(.top, RimSpacing.md)

                drawerSectionItems

                Spacer()

                Divider()
                    .background(theme.colors.textSecondary.opacity(0.15))
                    .padding(.horizontal, RimSpacing.xxl)

                RimDrawerSectionItem(
                    icon: .logout,
                    title: "Sign Out",
                    isSelected: false,
                    action: { store.send(.signOutTapped) }
                )
                .padding(.bottom, RimSpacing.sm)
            }
        }
    }

    @ViewBuilder
    private var drawerHeader: some View {
        HStack(spacing: 0) {
            // Flutter shell: Icons.science_outlined, primary
            RimIcon(.scienceOutlined, size: 24, color: theme.colors.primary)

            Spacer()
                .frame(width: 12)

            Text("Rick & Morty")
                .rimTextStyle(RimTypography.titleMedium)
                .fontWeight(.bold)
                .foregroundStyle(theme.colors.textPrimary)

            Spacer()

            Button {
                themeController.toggle()
            } label: {
                // Flutter: light_mode_outlined when dark (switch to light), else dark_mode_outlined
                RimIcon(
                    themeController.scheme == .dark ? .lightModeOutlined : .darkModeOutlined,
                    size: 24,
                    color: theme.colors.textPrimary
                )
                .frame(width: 40, height: 40)
            }
        }
        .padding(EdgeInsets(top: RimSpacing.xxl, leading: RimSpacing.xxl, bottom: RimSpacing.xl, trailing: RimSpacing.xxl))
    }

    @ViewBuilder
    private var drawerSectionItems: some View {
        VStack(spacing: 0) {
            RimDrawerSectionItem(
                icon: .peopleAltOutlined,
                title: "Characters",
                isSelected: store.selectedTab == .characters,
                action: { store.send(.tabSelected(.characters)) }
            )
            RimDrawerSectionItem(
                icon: .movieOutlined,
                title: "Episodes",
                isSelected: store.selectedTab == .episodes,
                action: { store.send(.tabSelected(.episodes)) }
            )
            RimDrawerSectionItem(
                icon: .publicOutlined,
                title: "Locations",
                isSelected: store.selectedTab == .locations,
                action: { store.send(.tabSelected(.locations)) }
            )
        }
        .padding(.top, RimSpacing.sm)
    }
}

// MARK: - Shell helpers

extension ShellTab {
    fileprivate var title: String {
        switch self {
        case .characters: "Characters"
        case .episodes: "Episodes"
        case .locations: "Locations"
        }
    }
}

// MARK: - Previews

#Preview("Dark") {
    ShellView(
        store: Store(initialState: ShellReducer.State()) {
            ShellReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .dark))
    .environment(RimThemeController(scheme: .dark))
}

#Preview("Light") {
    ShellView(
        store: Store(initialState: ShellReducer.State()) {
            ShellReducer()
        }
    )
    .rimTheme(RimTheme(scheme: .light))
    .environment(RimThemeController(scheme: .light))
}
