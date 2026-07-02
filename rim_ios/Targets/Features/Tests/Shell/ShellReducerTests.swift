import ComposableArchitecture
import Models
import XCTest

@testable import Features

final class ShellReducerTests: XCTestCase {
    @MainActor
    func test_signOutDelegatesLogout() async {
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        }

        await store.send(.signOutTapped)
        await store.receive(\.delegate.logout)
    }

    @MainActor
    func test_charactersScopeForwardsOnAppear() async {
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        } withDependencies: {
            $0.apiClient = .test(pages: [
                PageResult(
                    items: [
                        Character(
                            id: 1, name: "Rick", status: "Alive", species: "Human",
                            type: "", gender: "Male", image: "https://example.com/1.jpeg",
                            originName: "Earth", originUrl: "",
                            locationName: "Earth", locationUrl: "",
                            episodeIds: [1]
                        ),
                    ],
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
            $0.characters.items = IdentifiedArray(uniqueElements: [
                Character(
                    id: 1, name: "Rick", status: "Alive", species: "Human",
                    type: "", gender: "Male", image: "https://example.com/1.jpeg",
                    originName: "Earth", originUrl: "",
                    locationName: "Earth", locationUrl: "",
                    episodeIds: [1]
                ),
            ])
            $0.characters.page = 1
            $0.characters.hasNext = false
        }
    }

    @MainActor
    func test_signOutDoesNotCallTokenStore() async {
        // Verify the Shell reducer delegates logout without touching TokenStore directly.
        // TokenStore is injected as unimplemented — any call would trap.
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        } withDependencies: {
            $0.tokenStore = .init()
        }

        await store.send(.signOutTapped)
        await store.receive(\.delegate.logout)
    }
}
