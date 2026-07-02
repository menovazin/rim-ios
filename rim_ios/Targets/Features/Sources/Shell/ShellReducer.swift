import ComposableArchitecture
import DesignSystem
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
        public var locations: LocationsReducer.State

        public init(
            selectedTab: ShellTab = .characters,
            isDrawerOpen: Bool = false,
            characters: CharactersReducer.State = CharactersReducer.State(),
            charactersPath: StackState<CharactersPath.State> = StackState(),
            episodes: EpisodesReducer.State = EpisodesReducer.State(),
            locations: LocationsReducer.State = LocationsReducer.State()
        ) {
            self.selectedTab = selectedTab
            self.isDrawerOpen = isDrawerOpen
            self.characters = characters
            self.charactersPath = charactersPath
            self.episodes = episodes
            self.locations = locations
        }
    }

    @Reducer(state: .equatable)
    public enum CharactersPath {
        case characterDetail(CharacterDetailReducer)
    }

    public enum Action {
        case onAppear
        case tabSelected(ShellTab)
        case setDrawerOpen(Bool)
        case drawerOpenTapped
        case themeToggleTapped
        case signOutTapped
        case delegate(Delegate)

        case characters(CharactersReducer.Action)
        case charactersPath(StackAction<CharactersPath.State, CharactersPath.Action>)
        case episodes(EpisodesReducer.Action)
        case locations(LocationsReducer.Action)

        @CasePathable
        public enum Delegate: Equatable {
            case logout
        }
    }

    @Dependency(\.themeStore) var themeStore

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
                     .episodes,
                     .locations:
                    state.isDrawerOpen = true
                default:
                    break
                }
                return .none

            case .themeToggleTapped:
                let newScheme: RimColorScheme = (themeStore.load() ?? .dark) == .dark ? .light : .dark
                themeStore.save(newScheme)
                return .none

            case .signOutTapped:
                return .send(.delegate(.logout))

            case .delegate:
                return .none

            case let .characters(.cardTapped(character)):
                state.charactersPath.append(.characterDetail(CharacterDetailReducer.State(character: character)))
                return .none

            case .characters:
                return .none

            case .charactersPath:
                return .none

            case .episodes:
                return .none

            case .locations:
                return .none
            }
        }
        .forEach(\.charactersPath, action: \.charactersPath)
    }
}
