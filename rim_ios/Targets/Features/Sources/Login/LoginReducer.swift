import ComposableArchitecture
import Foundation

@Reducer
public struct LoginReducer {
    @ObservableState
    public struct State: Equatable {
        public var name: String = ""
        public var isSubmitting: Bool = false

        public init(name: String = "", isSubmitting: Bool = false) {
            self.name = name
            self.isSubmitting = isSubmitting
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signInTapped
        case saveTokenResponse
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable {
            case loginFinished
        }
    }

    @Dependency(\.tokenStore) var tokenStore
    @Dependency(\.continuousClock) var clock

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .signInTapped:
                if state.isSubmitting { return .none }
                state.isSubmitting = true

                let name = state.name.trimmingCharacters(in: .whitespaces)
                let resolvedName = name.isEmpty ? "guest" : name
                let token = "fake_\(resolvedName)_\(Int(Date.now.timeIntervalSince1970 * 1000))"

                return .run { send in
                    await tokenStore.saveToken(token)
                    await send(.saveTokenResponse)
                }

            case .saveTokenResponse:
                state.isSubmitting = false
                return .send(.delegate(.loginFinished))

            case .delegate:
                return .none
            }
        }
    }
}
