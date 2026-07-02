import ComposableArchitecture
import XCTest

@testable import Features

final class TokenStoreTests: XCTestCase {
    func test_saveAndRead() async {
        let store = TokenStore.test()
        await store.saveToken("fake_morty_123")
        let token = await store.getToken()
        XCTAssertEqual(token, "fake_morty_123")
    }

    func test_clearReturnsNil() async {
        let store = TokenStore.test(token: "existing")
        await store.clearToken()
        let token = await store.getToken()
        XCTAssertNil(token)
    }

    func test_noTokenIsNil() async {
        let store = TokenStore.inMemory
        let token = await store.getToken()
        XCTAssertNil(token)
    }

    func test_seededTokenIsReturned() async {
        let store = TokenStore.test(token: "seeded")
        let token = await store.getToken()
        XCTAssertEqual(token, "seeded")
    }
}
