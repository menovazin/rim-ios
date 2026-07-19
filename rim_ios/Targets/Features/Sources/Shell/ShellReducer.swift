import ComposableArchitecture
import Foundation

/// The primary tabs inside the signed-in Shell.
public enum ShellTab: Equatable, Sendable, CaseIterable {
    case characters
    case episodes
    case locations
}

@Reducer
public struct ShellReducer {
    @ObservableState
    public struct State: Equatable {
        public var selectedTab: ShellTab
        public var isDrawerOpen: Bool

        public var characters: CharactersReducer.State
        public var charactersPath: StackState<CharactersPath.State>

        public var episodes: EpisodesReducer.State
        public var episodesPath: StackState<EpisodesPath.State>

        public var locations: LocationsReducer.State
        public var locationsPath: StackState<LocationsPath.State>

        public init(
            selectedTab: ShellTab = .characters,
            isDrawerOpen: Bool = false,
            characters: CharactersReducer.State = CharactersReducer.State(),
            charactersPath: StackState<CharactersPath.State> = StackState(),
            episodes: EpisodesReducer.State = EpisodesReducer.State(),
            episodesPath: StackState<EpisodesPath.State> = StackState(),
            locations: LocationsReducer.State = LocationsReducer.State(),
            locationsPath: StackState<LocationsPath.State> = StackState()
        ) {
            self.selectedTab = selectedTab
            self.isDrawerOpen = isDrawerOpen
            self.characters = characters
            self.charactersPath = charactersPath
            self.episodes = episodes
            self.episodesPath = episodesPath
            self.locations = locations
            self.locationsPath = locationsPath
        }
    }

    @Reducer(state: .equatable)
    public enum CharactersPath {
        case characterDetail(CharacterDetailReducer)
    }

    @Reducer(state: .equatable)
    public enum EpisodesPath {
        case episodeDetail(EpisodeDetailReducer)
    }

    @Reducer(state: .equatable)
    public enum LocationsPath {
        case locationDetail(LocationDetailReducer)
    }

    public enum Action {
        case onAppear
        case tabSelected(ShellTab)
        case setDrawerOpen(Bool)
        case drawerOpenTapped
        case signOutTapped
        case themeToggleTapped
        case delegate(Delegate)

        case characters(CharactersReducer.Action)
        case charactersPath(StackAction<CharactersPath.State, CharactersPath.Action>)
        case episodes(EpisodesReducer.Action)
        case episodesPath(StackAction<EpisodesPath.State, EpisodesPath.Action>)
        case locations(LocationsReducer.Action)
        case locationsPath(StackAction<LocationsPath.State, LocationsPath.Action>)

        @CasePathable
        public enum Delegate: Equatable {
            case logout
            case themeToggleTapped
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.characters, action: \.characters) {
            CharactersReducer()
        }
        Scope(state: \.episodes, action: \.episodes) {
            EpisodesReducer()
        }
        Scope(state: \.locations, action: \.locations) {
            LocationsReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case let .tabSelected(tab):
                state.selectedTab = tab
                state.isDrawerOpen = false
                return .none

            case let .setDrawerOpen(isOpen):
                state.isDrawerOpen = isOpen
                return .none

            case .drawerOpenTapped:
                switch state.selectedTab {
                case .characters where state.charactersPath.isEmpty,
                     .episodes where state.episodesPath.isEmpty,
                     .locations where state.locationsPath.isEmpty:
                    state.isDrawerOpen = true
                default:
                    break
                }
                return .none

            case .signOutTapped:
                return .send(.delegate(.logout))

            case .themeToggleTapped:
                return .send(.delegate(.themeToggleTapped))

            case .delegate:
                return .none

            case let .characters(.cardTapped(character)):
                state.charactersPath.append(.characterDetail(CharacterDetailReducer.State(character: character)))
                return .none

            case .characters:
                return .none

            case .charactersPath:
                return .none

            case let .episodes(.cardTapped(episode)):
                state.episodesPath.append(.episodeDetail(EpisodeDetailReducer.State(episode: episode)))
                return .none

            case .episodes:
                return .none

            case .episodesPath:
                return .none

            case let .locations(.cardTapped(location)):
                state.locationsPath.append(.locationDetail(LocationDetailReducer.State(location: location)))
                return .none

            case .locations:
                return .none

            case .locationsPath:
                return .none
            }
        }
        .forEach(\.charactersPath, action: \.charactersPath)
        .forEach(\.episodesPath, action: \.episodesPath)
        .forEach(\.locationsPath, action: \.locationsPath)
    }
}
