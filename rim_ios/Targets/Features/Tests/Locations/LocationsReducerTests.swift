import ComposableArchitecture
import XCTest
import Models

@testable import Features

final class LocationsReducerTests: XCTestCase {
    // MARK: - Helpers

    private func location(id: Int, name: String = "Earth", type: String = "Planet") -> Location {
        Location(
            id: id, name: name, type: type,
            dimension: "Dimension C-137",
            residentIds: [1, 2]
        )
    }

    private func pageResult(
        ids: [Int],
        page: Int = 1,
        hasNext: Bool = true
    ) -> PageResult<Location> {
        PageResult(
            items: ids.map { location(id: $0) },
            page: page,
            totalPages: 5,
            hasNext: hasNext
        )
    }

    // MARK: - Initial load

    @MainActor
    func test_onAppear_triggersInitialLoad() async {
        let store = TestStore(initialState: LocationsReducer.State()) {
            LocationsReducer()
        } withDependencies: {
            $0.apiClient = .test(locations: [pageResult(ids: [1, 2])])
        }

        await store.send(.onAppear)
        await store.receive(\.loadInitial) {
            $0.isLoadingInitial = true
        }
        await store.receive(\.loadInitialResponse.success) {
            $0.isLoadingInitial = false
            $0.items = IdentifiedArray(uniqueElements: [self.location(id: 1), self.location(id: 2)])
            $0.page = 1
            $0.hasNext = true
        }
    }

    @MainActor
    func test_onAppear_keptAlive_noOpWhenItemsExist() async {
        let existing = [location(id: 99)]
        let state = LocationsReducer.State(
            items: IdentifiedArray(uniqueElements: existing)
        )
        let store = TestStore(initialState: state) {
            LocationsReducer()
        }

        await store.send(.onAppear)
    }

    @MainActor
    func test_initialLoadFailure_setsLoadFailed() async {
        let store = TestStore(initialState: LocationsReducer.State()) {
            LocationsReducer()
        } withDependencies: {
            $0.apiClient = .failingLocations()
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
        let initial = LocationsReducer.State(
            items: IdentifiedArray(uniqueElements: [location(id: 1)]),
            page: 1,
            hasNext: true
        )
        let store = TestStore(initialState: initial) {
            LocationsReducer()
        } withDependencies: {
            $0.apiClient = .test(locations: [pageResult(ids: [2, 3], page: 2, hasNext: true)])
        }

        await store.send(.loadMore) {
            $0.isLoadingMore = true
            $0.loadMoreFailed = false
        }
        await store.receive(\.loadMoreResponse.success) {
            $0.isLoadingMore = false
            $0.items = IdentifiedArray(uniqueElements: [
                self.location(id: 1), self.location(id: 2), self.location(id: 3),
            ])
            $0.page = 2
            $0.hasNext = true
        }
    }

    @MainActor
    func test_loadMore_flipsHasNextOnLastPage() async {
        let initial = LocationsReducer.State(
            items: IdentifiedArray(uniqueElements: [location(id: 1)]),
            page: 4,
            hasNext: true
        )
        let store = TestStore(initialState: initial) {
            LocationsReducer()
        } withDependencies: {
            $0.apiClient = .test(locations: [pageResult(ids: [2], page: 5, hasNext: false)])
        }

        await store.send(.loadMore) {
            $0.isLoadingMore = true
        }
        await store.receive(\.loadMoreResponse.success) {
            $0.isLoadingMore = false
            $0.items = IdentifiedArray(uniqueElements: [self.location(id: 1), self.location(id: 2)])
            $0.page = 5
            $0.hasNext = false
        }
    }

    @MainActor
    func test_loadMore_failure_setsLoadMoreFailed() async {
        let initial = LocationsReducer.State(
            items: IdentifiedArray(uniqueElements: [location(id: 1)]),
            page: 1,
            hasNext: true
        )
        let store = TestStore(initialState: initial) {
            LocationsReducer()
        } withDependencies: {
            $0.apiClient = .failingLocations()
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
        let initial = LocationsReducer.State(
            items: IdentifiedArray(uniqueElements: [location(id: 1)]),
            page: 1,
            hasNext: true,
            isLoadingMore: true
        )
        let store = TestStore(initialState: initial) {
            LocationsReducer()
        }

        await store.send(.loadMore)
    }

    @MainActor
    func test_loadMore_noOpWhenHasNextFalse() async {
        let initial = LocationsReducer.State(
            items: IdentifiedArray(uniqueElements: [location(id: 1)]),
            page: 5,
            hasNext: false
        )
        let store = TestStore(initialState: initial) {
            LocationsReducer()
        }

        await store.send(.loadMore)
    }

    @MainActor
    func test_loadMore_noOpWhenLoadingInitial() async {
        let initial = LocationsReducer.State(
            isLoadingInitial: true,
            isLoadingMore: false
        )
        let store = TestStore(initialState: initial) {
            LocationsReducer()
        }

        await store.send(.loadMore)
    }

    // MARK: - Retry

    @MainActor
    func test_retry_afterInitialError_reloadsPage1() async {
        let initial = LocationsReducer.State(
            items: [],
            page: 1,
            hasNext: true,
            loadFailed: true
        )
        let store = TestStore(initialState: initial) {
            LocationsReducer()
        } withDependencies: {
            $0.apiClient = .test(locations: [pageResult(ids: [1])])
        }

        await store.send(.retry) {
            $0.loadFailed = false
        }
        await store.receive(\.loadInitial) {
            $0.isLoadingInitial = true
        }
        await store.receive(\.loadInitialResponse.success) {
            $0.isLoadingInitial = false
            $0.items = IdentifiedArray(uniqueElements: [self.location(id: 1)])
            $0.page = 1
            $0.hasNext = true
        }
    }

    @MainActor
    func test_retry_afterPaginationError_reloadsNextPage() async {
        let initial = LocationsReducer.State(
            items: IdentifiedArray(uniqueElements: [location(id: 1)]),
            page: 2,
            hasNext: true,
            loadMoreFailed: true
        )
        let store = TestStore(initialState: initial) {
            LocationsReducer()
        } withDependencies: {
            $0.apiClient = .test(locations: [pageResult(ids: [3], page: 3, hasNext: true)])
        }

        await store.send(.retry) {
            $0.loadMoreFailed = false
        }
        await store.receive(\.loadMore) {
            $0.isLoadingMore = true
        }
        await store.receive(\.loadMoreResponse.success) {
            $0.isLoadingMore = false
            $0.items = IdentifiedArray(uniqueElements: [self.location(id: 1), self.location(id: 3)])
            $0.page = 3
            $0.hasNext = true
        }
    }

    // MARK: - cardTapped delegates selection

    @MainActor
    func test_cardTapped_doesNotMutateState() async {
        let tapped = location(id: 1)
        let store = TestStore(initialState: LocationsReducer.State()) {
            LocationsReducer()
        }

        await store.send(.cardTapped(tapped))
    }

    @MainActor
    func test_cardTapped_leavesListStateUnchanged() async {
        let tapped = location(id: 7)
        let initial = LocationsReducer.State(
            items: IdentifiedArray(uniqueElements: [location(id: 1), tapped]),
            page: 2,
            hasNext: false,
            isLoadingMore: false
        )
        let store = TestStore(initialState: initial) {
            LocationsReducer()
        }

        await store.send(.cardTapped(tapped))
    }
}
