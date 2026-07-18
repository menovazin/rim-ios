import ComposableArchitecture
import Foundation
import Models

/// Paginated Episodes list reducer matching `episodes_page.dart`.
///
/// Mirrors `CharactersReducer`'s pagination shape exactly: kept-alive initial
/// load, guarded load-more, retry after error.
@Reducer
public struct EpisodesReducer {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var items: IdentifiedArrayOf<Episode>
        public var page: Int
        public var hasNext: Bool
        public var isLoadingInitial: Bool
        public var isLoadingMore: Bool
        public var loadFailed: Bool
        public var loadMoreFailed: Bool

        public init(
            items: IdentifiedArrayOf<Episode> = [],
            page: Int = 1,
            hasNext: Bool = true,
            isLoadingInitial: Bool = false,
            isLoadingMore: Bool = false,
            loadFailed: Bool = false,
            loadMoreFailed: Bool = false
        ) {
            self.items = items
            self.page = page
            self.hasNext = hasNext
            self.isLoadingInitial = isLoadingInitial
            self.isLoadingMore = isLoadingMore
            self.loadFailed = loadFailed
            self.loadMoreFailed = loadMoreFailed
        }
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case loadInitial
        case loadInitialResponse(Result<PageResult<Episode>, NSError>)
        case loadMore
        case loadMoreResponse(Result<PageResult<Episode>, NSError>)
        case retry
        case cardTapped(Episode)
    }

    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.items.isEmpty, !state.isLoadingInitial else { return .none }
                return .send(.loadInitial)

            case .loadInitial:
                guard !state.isLoadingInitial else { return .none }
                state.isLoadingInitial = true
                state.loadFailed = false
                let page = 1
                return .run { send in
                    do {
                        let result = try await apiClient.fetchEpisodes(page)
                        await send(.loadInitialResponse(.success(result)))
                    } catch {
                        await send(.loadInitialResponse(.failure(error as NSError)))
                    }
                }

            case let .loadInitialResponse(.success(result)):
                state.isLoadingInitial = false
                state.items = IdentifiedArray(uniqueElements: result.items)
                state.page = result.page
                state.hasNext = result.hasNext
                return .none

            case let .loadInitialResponse(.failure):
                state.isLoadingInitial = false
                state.loadFailed = true
                return .none

            case .loadMore:
                guard !state.isLoadingMore, state.hasNext, !state.isLoadingInitial else {
                    return .none
                }
                state.isLoadingMore = true
                state.loadMoreFailed = false
                let nextPage = state.page + 1
                return .run { send in
                    do {
                        let result = try await apiClient.fetchEpisodes(nextPage)
                        await send(.loadMoreResponse(.success(result)))
                    } catch {
                        await send(.loadMoreResponse(.failure(error as NSError)))
                    }
                }

            case let .loadMoreResponse(.success(result)):
                state.isLoadingMore = false
                state.items.append(contentsOf: result.items)
                state.page = result.page
                state.hasNext = result.hasNext
                return .none

            case let .loadMoreResponse(.failure):
                state.isLoadingMore = false
                state.loadMoreFailed = true
                return .none

            case .retry:
                if state.items.isEmpty {
                    guard !state.isLoadingInitial else { return .none }
                    state.loadFailed = false
                    return .send(.loadInitial)
                } else {
                    guard !state.isLoadingMore, state.hasNext else { return .none }
                    state.loadMoreFailed = false
                    return .send(.loadMore)
                }

            case .cardTapped:
                return .none
            }
        }
    }
}
