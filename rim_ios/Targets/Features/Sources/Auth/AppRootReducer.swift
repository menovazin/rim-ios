import ComposableArchitecture
import DesignSystem

@Reducer
public enum AppRootDestination {
    case login(LoginReducer)
    case shell(ShellReducer)
}

extension AppRootDestination.State: Equatable {}

@Reducer
public struct AppRoot {
    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: AppRootDestination.State?
        /// Guards against redundant routing on repeated `onAppear` calls.
        public var hasAppeared: Bool = false
        /// Product theme preference (persisted via `ThemeStore`, key `"theme"`).
        public var themePreference: RimThemePreference = .system

        public init(
            destination: AppRootDestination.State? = nil,
            hasAppeared: Bool = false,
            themePreference: RimThemePreference = .system
        ) {
            self.destination = destination
            self.hasAppeared = hasAppeared
            self.themePreference = themePreference
        }
    }

    public enum Action {
        case onAppear
        case routeResolved(AppRootDestination.State)
        case destination(PresentationAction<AppRootDestination.Action>)
    }

    @Dependency(\.tokenStore) var tokenStore
    @Dependency(\.themeStore) var themeStore

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.hasAppeared { return .none }
                state.hasAppeared = true
                state.themePreference = themeStore.load() ?? .system

                return .run { send in
                    let token = await tokenStore.getToken()
                    if let token, !token.isEmpty {
                        await send(.routeResolved(.shell(ShellReducer.State())))
                    } else {
                        await send(.routeResolved(.login(LoginReducer.State())))
                    }
                }

            case .routeResolved(let destination):
                state.destination = destination
                return .none

            case .destination(.presented(.login(.delegate(.loginFinished)))):
                state.destination = .shell(ShellReducer.State())
                return .none

            case .destination(.presented(.shell(.delegate(.logout)))):
                state.destination = nil
                return .run { send in
                    await tokenStore.clearToken()
                    await send(.routeResolved(.login(LoginReducer.State())))
                }

            case .destination(.presented(.shell(.delegate(.themeToggleTapped)))):
                let next = state.themePreference.toggled
                state.themePreference = next
                themeStore.save(next)
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
