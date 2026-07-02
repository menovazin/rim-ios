import ComposableArchitecture
import Models
import XCTest

@testable import Features

final class ShellReducerTests: XCTestCase {
    private func character(id: Int) -> Character {
        Character(
            id: id, name: "Rick", status: "Alive", species: "Human",
            type: "", gender: "Male", image: "https://example.com/\(id).jpeg",
            originName: "Earth", originUrl: "",
            locationName: "Earth", locationUrl: "",
            episodeIds: [1]
        )
    }

    // MARK: - Drawer / tabs

    @MainActor
    func test_tabSelected_updatesTabAndClosesDrawer() async {
        let store = TestStore(initialState: ShellReducer.State(
            selectedTab: .characters,
            isDrawerOpen: true
        )) {
            ShellReducer()
        }

        await store.send(.tabSelected(.episodes)) {
            $0.selectedTab = .episodes
            $0.isDrawerOpen = false
        }
    }

    @MainActor
    func test_drawerOpenTapped_opensDrawerAtStackRoot() async {
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        }

        await store.send(.drawerOpenTapped) {
            $0.isDrawerOpen = true
        }
    }

    @MainActor
    func test_drawerOpenTapped_doesNotOpenWhenDetailPushed() async {
        let character = self.character(id: 1)
        let store = TestStore(initialState: ShellReducer.State(
            charactersPath: StackState([
                .characterDetail(CharacterDetailReducer.State(character: character))
            ])
        )) {
            ShellReducer()
        }

        await store.send(.drawerOpenTapped)
    }

    @MainActor
    func test_setDrawerOpen() async {
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        }

        await store.send(.setDrawerOpen(true)) {
            $0.isDrawerOpen = true
        }
    }

    // MARK: - Theme toggle

    @MainActor
    func test_themeToggleTapped_flipsAndPersistsScheme() async {
        let themeStore = ThemeStore.test(scheme: .dark)
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        } withDependencies: {
            $0.themeStore = themeStore
        }

        await store.send(.themeToggleTapped)
        XCTAssertEqual(themeStore.load(), .light)
    }

    @MainActor
    func test_themeToggleTapped_flipsLightToDark() async {
        let themeStore = ThemeStore.test(scheme: .light)
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        } withDependencies: {
            $0.themeStore = themeStore
        }

        await store.send(.themeToggleTapped)
        XCTAssertEqual(themeStore.load(), .dark)
    }

    // MARK: - Sign Out

    @MainActor
    func test_signOutTapped_delegatesLogout() async {
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        }

        await store.send(.signOutTapped)
        await store.receive(\.delegate.logout)
    }

    @MainActor
    func test_signOutDoesNotCallTokenStore() async {
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        } withDependencies: {
            $0.tokenStore = .init()
        }

        await store.send(.signOutTapped)
        await store.receive(\.delegate.logout)
    }

    // MARK: - Per-tab stack preservation

    @MainActor
    func test_switchingTabs_preservesCharactersStack() async {
        let character = self.character(id: 1)
        let store = TestStore(initialState: ShellReducer.State(
            selectedTab: .characters,
            charactersPath: StackState([
                .characterDetail(CharacterDetailReducer.State(character: character))
            ])
        )) {
            ShellReducer()
        }

        await store.send(.tabSelected(.episodes)) {
            $0.selectedTab = .episodes
            $0.isDrawerOpen = false
        }

        await store.send(.tabSelected(.characters)) {
            $0.selectedTab = .characters
            $0.isDrawerOpen = false
        }

        XCTAssertEqual(store.state.charactersPath.count, 1)
    }

    // MARK: - Detail navigation

    @MainActor
    func test_cardTapped_pushesCharacterDetail() async {
        let character = self.character(id: 1)
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        }

        await store.send(.characters(.cardTapped(character))) {
            $0.charactersPath.append(.characterDetail(CharacterDetailReducer.State(character: character)))
        }
    }

    // MARK: - Episodes detail navigation

    @MainActor
    func test_episodeCardTapped_pushesEpisodeDetail() async {
        let episode = Episode(
            id: 1, name: "Pilot", episodeCode: "S01E01",
            airDate: "December 2, 2013",
            characterIds: [1, 2]
        )
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        }

        await store.send(.episodes(.cardTapped(episode))) {
            $0.episodesPath.append(.episodeDetail(EpisodeDetailReducer.State(episode: episode)))
        }
    }

    @MainActor
    func test_episodeCardTapped_leavesEpisodesListStateUnchanged() async {
        let episode = Episode(
            id: 1, name: "Pilot", episodeCode: "S01E01",
            airDate: "December 2, 2013",
            characterIds: [1]
        )
        let store = TestStore(initialState: ShellReducer.State(
            episodes: EpisodesReducer.State(
                items: IdentifiedArray(uniqueElements: [episode]),
                page: 1,
                hasNext: false
            )
        )) {
            ShellReducer()
        }

        await store.send(.episodes(.cardTapped(episode))) {
            $0.episodesPath.append(.episodeDetail(EpisodeDetailReducer.State(episode: episode)))
        }
        XCTAssertEqual(store.state.episodes.items.count, 1)
        XCTAssertEqual(store.state.episodes.page, 1)
        XCTAssertEqual(store.state.episodes.hasNext, false)
    }

    @MainActor
    func test_switchingTabs_preservesEpisodesStack() async {
        let episode = Episode(
            id: 1, name: "Pilot", episodeCode: "S01E01",
            airDate: "December 2, 2013",
            characterIds: [1]
        )
        let store = TestStore(initialState: ShellReducer.State(
            selectedTab: .episodes,
            episodesPath: StackState([
                .episodeDetail(EpisodeDetailReducer.State(episode: episode))
            ])
        )) {
            ShellReducer()
        }

        await store.send(.tabSelected(.characters)) {
            $0.selectedTab = .characters
            $0.isDrawerOpen = false
        }

        await store.send(.tabSelected(.episodes)) {
            $0.selectedTab = .episodes
            $0.isDrawerOpen = false
        }

        XCTAssertEqual(store.state.episodesPath.count, 1)
    }

    // MARK: - Drawer / episodes tab

    @MainActor
    func test_drawerOpenTapped_opensDrawerForEpisodesAtRoot() async {
        let store = TestStore(initialState: ShellReducer.State(
            selectedTab: .episodes
        )) {
            ShellReducer()
        }

        await store.send(.drawerOpenTapped) {
            $0.isDrawerOpen = true
        }
    }

    @MainActor
    func test_drawerOpenTapped_blockedWhenEpisodeDetailPushed() async {
        let episode = Episode(
            id: 1, name: "Pilot", episodeCode: "S01E01",
            airDate: "December 2, 2013",
            characterIds: [1]
        )
        let store = TestStore(initialState: ShellReducer.State(
            selectedTab: .episodes,
            episodesPath: StackState([
                .episodeDetail(EpisodeDetailReducer.State(episode: episode))
            ])
        )) {
            ShellReducer()
        }

        await store.send(.drawerOpenTapped)
    }

    // MARK: - Characters scope still forwards

    @MainActor
    func test_charactersScopeForwardsOnAppear() async {
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        } withDependencies: {
            $0.apiClient = .test(pages: [
                PageResult(
                    items: [character(id: 1)],
                    page: 1,
                    totalPages: 1,
                    hasNext: false
                ),
            ])
        }

        await store.send(.characters(.onAppear))
        await store.receive(\.characters.loadInitial) {
            $0.characters.isLoadingInitial = true
        }
        await store.receive(\.characters.loadInitialResponse.success) {
            $0.characters.isLoadingInitial = false
            $0.characters.items = IdentifiedArray(uniqueElements: [self.character(id: 1)])
            $0.characters.page = 1
            $0.characters.hasNext = false
        }
    }

    // MARK: - Locations detail navigation

    @MainActor
    func test_locationCardTapped_pushesLocationDetail() async {
        let location = Location(
            id: 1, name: "Earth", type: "Planet",
            dimension: "Dimension C-137",
            residentIds: [1, 2]
        )
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        }

        await store.send(.locations(.cardTapped(location))) {
            $0.locationsPath.append(.locationDetail(LocationDetailReducer.State(location: location)))
        }
    }

    @MainActor
    func test_locationCardTapped_leavesLocationsListStateUnchanged() async {
        let location = Location(
            id: 1, name: "Earth", type: "Planet",
            dimension: "Dimension C-137",
            residentIds: [1]
        )
        let store = TestStore(initialState: ShellReducer.State(
            locations: LocationsReducer.State(
                items: IdentifiedArray(uniqueElements: [location]),
                page: 1,
                hasNext: false
            )
        )) {
            ShellReducer()
        }

        await store.send(.locations(.cardTapped(location))) {
            $0.locationsPath.append(.locationDetail(LocationDetailReducer.State(location: location)))
        }
        XCTAssertEqual(store.state.locations.items.count, 1)
        XCTAssertEqual(store.state.locations.page, 1)
        XCTAssertEqual(store.state.locations.hasNext, false)
    }

    @MainActor
    func test_switchingTabs_preservesLocationsStack() async {
        let location = Location(
            id: 1, name: "Earth", type: "Planet",
            dimension: "Dimension C-137",
            residentIds: [1]
        )
        let store = TestStore(initialState: ShellReducer.State(
            selectedTab: .locations,
            locationsPath: StackState([
                .locationDetail(LocationDetailReducer.State(location: location))
            ])
        )) {
            ShellReducer()
        }

        await store.send(.tabSelected(.characters)) {
            $0.selectedTab = .characters
            $0.isDrawerOpen = false
        }

        await store.send(.tabSelected(.locations)) {
            $0.selectedTab = .locations
            $0.isDrawerOpen = false
        }

        XCTAssertEqual(store.state.locationsPath.count, 1)
    }

    // MARK: - Drawer / locations tab

    @MainActor
    func test_drawerOpenTapped_opensDrawerForLocationsAtRoot() async {
        let store = TestStore(initialState: ShellReducer.State(
            selectedTab: .locations
        )) {
            ShellReducer()
        }

        await store.send(.drawerOpenTapped) {
            $0.isDrawerOpen = true
        }
    }

    @MainActor
    func test_drawerOpenTapped_blockedWhenLocationDetailPushed() async {
        let location = Location(
            id: 1, name: "Earth", type: "Planet",
            dimension: "Dimension C-137",
            residentIds: [1]
        )
        let store = TestStore(initialState: ShellReducer.State(
            selectedTab: .locations,
            locationsPath: StackState([
                .locationDetail(LocationDetailReducer.State(location: location))
            ])
        )) {
            ShellReducer()
        }

        await store.send(.drawerOpenTapped)
    }
}
