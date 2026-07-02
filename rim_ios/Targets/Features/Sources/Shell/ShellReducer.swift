import ComposableArchitecture

@Reducer
public struct ShellReducer {
    @ObservableState
    public struct State: Equatable {}

    public enum Action {
        case onAppear
        case signOutTapped
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable {
            case logout
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .signOutTapped:
                return .send(.delegate(.logout))

            case .delegate:
                return .none
            }
        }
    }
}
