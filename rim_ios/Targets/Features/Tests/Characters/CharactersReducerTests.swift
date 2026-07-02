import ComposableArchitecture
import XCTest
import Models

@testable import Features

final class CharactersReducerTests: XCTestCase {
    // MARK: - Helpers

    private func character(id: Int, name: String = "Rick", status: String = "Alive") -> Character {
        Character(
            id: id, name: name, status: status, species: "Human",
            type: "", gender: "Male", image: "https://example.com/\(id).jpeg",
            originName: "Earth", originUrl: "",
            locationName: "Earth", locationUrl: "",
            episodeIds: [1]
        )
    }

    private func pageResult(
        ids: [Int],
        page: Int = 1,
        hasNext: Bool = true
    ) -> PageResult<Character> {
        PageResult(
            items: ids.map { character(id: $0) },
            page: page,
            totalPages: 5,
            hasNext: hasNext
        )
    }

    // MARK: - Initial load

    @MainActor
    func test_onAppear_triggersInitialLoad() async {
        let store = TestStore(initialState: CharactersReducer.State()) {
            CharactersReducer()
        } withDependencies: {
            $0.apiClient = .test(pages: [pageResult(ids: [1, 2])])
        }

        await store.send(.onAppear)
        await store.receive(\.loadInitial) {
            $0.isLoadingInitial = true
        }
        await store.receive(\.loadInitialResponse.success) {
            $0.isLoadingInitial = false
            $0.items = IdentifiedArray(uniqueElements: [self.character(id: 1), self.character(id: 2)])
            $0.page = 1
            $0.hasNext = true
        }
    }

    @MainActor
    func test_onAppear_keptAlive_noOpWhenItemsExist() async {
        let existing = [character(id: 99)]
        let state = CharactersReducer.State(
            items: IdentifiedArray(uniqueElements: existing)
        )
        let store = TestStore(initialState: state) {
            CharactersReducer()
        }

        await store.send(.onAppear)
    }

    @MainActor
    func test_initialLoadFailure_setsLoadFailed() async {
        let store = TestStore(initialState: CharactersReducer.State()) {
            CharactersReducer()
        } withDependencies: {
            $0.apiClient = .failing()
        }

        await store.send(.onAppear)
        await store.receive(\.loadInitial) {
            $0.isLoadingInitial = true
        }
        await store.receive(\.loadInitialResponse.failure) {
            $0.isLoadingInitial = false
            $0.loadFailed = true
        }
    }

    // MARK: - Load more

    @MainActor
    func test_loadMore_appendsAndAdvancesPage() async {
        let initial = CharactersReducer.State(
            items: IdentifiedArray(uniqueElements: [character(id: 1)]),
            page: 1,
            hasNext: true
        )
        let store = TestStore(initialState: initial) {
            CharactersReducer()
        } withDependencies: {
            $0.apiClient = .test(pages: [pageResult(ids: [2, 3], page: 2, hasNext: true)])
        }

        await store.send(.loadMore) {
            $0.isLoadingMore = true
            $0.loadMoreFailed = false
        }
        await store.receive(\.loadMoreResponse.success) {
            $0.isLoadingMore = false
            $0.items = IdentifiedArray(uniqueElements: [
                self.character(id: 1), self.character(id: 2), self.character(id: 3),
            ])
            $0.page = 2
            $0.hasNext = true
        }
    }

    @MainActor
    func test_loadMore_flipsHasNextOnLastPage() async {
        let initial = CharactersReducer.State(
            items: IdentifiedArray(uniqueElements: [character(id: 1)]),
            page: 4,
            hasNext: true
        )
        let store = TestStore(initialState: initial) {
            CharactersReducer()
        } withDependencies: {
            $0.apiClient = .test(pages: [pageResult(ids: [2], page: 5, hasNext: false)])
        }

        await store.send(.loadMore) {
            $0.isLoadingMore = true
        }
        await store.receive(\.loadMoreResponse.success) {
            $0.isLoadingMore = false
            $0.items = IdentifiedArray(uniqueElements: [self.character(id: 1), self.character(id: 2)])
            $0.page = 5
            $0.hasNext = false
        }
    }

    @MainActor
    func test_loadMore_failure_setsLoadMoreFailed() async {
        let initial = CharactersReducer.State(
            items: IdentifiedArray(uniqueElements: [character(id: 1)]),
            page: 1,
            hasNext: true
        )
        let store = TestStore(initialState: initial) {
            CharactersReducer()
        } withDependencies: {
            $0.apiClient = .failing()
        }

        await store.send(.loadMore) {
            $0.isLoadingMore = true
        }
        await store.receive(\.loadMoreResponse.failure) {
            $0.isLoadingMore = false
            $0.loadMoreFailed = true
        }
    }

    // MARK: - Guards

    @MainActor
    func test_loadMore_noOpWhenAlreadyLoading() async {
        let initial = CharactersReducer.State(
            items: IdentifiedArray(uniqueElements: [character(id: 1)]),
            page: 1,
            hasNext: true,
            isLoadingMore: true
        )
        let store = TestStore(initialState: initial) {
            CharactersReducer()
        }

        await store.send(.loadMore)
    }

    @MainActor
    func test_loadMore_noOpWhenHasNextFalse() async {
        let initial = CharactersReducer.State(
            items: IdentifiedArray(uniqueElements: [character(id: 1)]),
            page: 5,
            hasNext: false
        )
        let store = TestStore(initialState: initial) {
            CharactersReducer()
        }

        await store.send(.loadMore)
    }

    @MainActor
    func test_loadMore_noOpWhenLoadingInitial() async {
        let initial = CharactersReducer.State(
            isLoadingInitial: true,
            isLoadingMore: false
        )
        let store = TestStore(initialState: initial) {
            CharactersReducer()
        }

        await store.send(.loadMore)
    }

    // MARK: - Retry

    @MainActor
    func test_retry_afterInitialError_reloadsPage1() async {
        let initial = CharactersReducer.State(
            items: [],
            page: 1,
            hasNext: true,
            loadFailed: true
        )
        let store = TestStore(initialState: initial) {
            CharactersReducer()
        } withDependencies: {
            $0.apiClient = .test(pages: [pageResult(ids: [1])])
        }

        await store.send(.retry) {
            $0.loadFailed = false
        }
        await store.receive(\.loadInitial) {
            $0.isLoadingInitial = true
        }
        await store.receive(\.loadInitialResponse.success) {
            $0.isLoadingInitial = false
            $0.items = IdentifiedArray(uniqueElements: [self.character(id: 1)])
            $0.page = 1
            $0.hasNext = true
        }
    }

    @MainActor
    func test_retry_afterPaginationError_reloadsNextPage() async {
        let initial = CharactersReducer.State(
            items: IdentifiedArray(uniqueElements: [character(id: 1)]),
            page: 2,
            hasNext: true,
            loadMoreFailed: true
        )
        let store = TestStore(initialState: initial) {
            CharactersReducer()
        } withDependencies: {
            $0.apiClient = .test(pages: [pageResult(ids: [3], page: 3, hasNext: true)])
        }

        await store.send(.retry) {
            $0.loadMoreFailed = false
        }
        await store.receive(\.loadMore) {
            $0.isLoadingMore = true
        }
        await store.receive(\.loadMoreResponse.success) {
            $0.isLoadingMore = false
            $0.items = IdentifiedArray(uniqueElements: [self.character(id: 1), self.character(id: 3)])
            $0.page = 3
            $0.hasNext = true
        }
    }

    // MARK: - cardTapped delegates selection

    @MainActor
    func test_cardTapped_doesNotMutateState() async {
        let tapped = character(id: 1)
        let store = TestStore(initialState: CharactersReducer.State()) {
            CharactersReducer()
        }

        await store.send(.cardTapped(tapped))
    }

    @MainActor
    func test_cardTapped_leavesGridStateUnchanged() async {
        let tapped = character(id: 7)
        let initial = CharactersReducer.State(
            items: IdentifiedArray(uniqueElements: [character(id: 1), tapped]),
            page: 2,
            hasNext: false,
            isLoadingMore: false
        )
        let store = TestStore(initialState: initial) {
            CharactersReducer()
        }

        await store.send(.cardTapped(tapped))
    }
}
