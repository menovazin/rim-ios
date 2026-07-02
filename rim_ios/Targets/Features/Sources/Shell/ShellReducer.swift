import ComposableArchitecture

@Reducer
public struct ShellReducer {
    @ObservableState
    public struct State: Equatable {
        public var characters: CharactersReducer.State

        public init(characters: CharactersReducer.State = CharactersReducer.State()) {
            self.characters = characters
        }
    }

    public enum Action {
        case onAppear
        case characters(CharactersReducer.Action)
        case signOutTapped
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable {
            case logout
        }
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.characters, action: \.characters) {
            CharactersReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .characters:
                return .none

            case .signOutTapped:
                return .send(.delegate(.logout))

            case .delegate:
                return .none
            }
        }
    }
}
