import XCTest
@testable import Models

final class ModelsTests: XCTestCase {
    func test_moduleName() {
        XCTAssertEqual(ModelsModule.name, "Models")
    }
}

// MARK: - CharacterStatus

final class CharacterStatusTests: XCTestCase {
    func test_aliveCaseInsensitive() {
        XCTAssertEqual(CharacterStatus(rawString: "alive"), .alive)
        XCTAssertEqual(CharacterStatus(rawString: "Alive"), .alive)
        XCTAssertEqual(CharacterStatus(rawString: "ALIVE"), .alive)
    }

    func test_deadCaseInsensitive() {
        XCTAssertEqual(CharacterStatus(rawString: "dead"), .dead)
        XCTAssertEqual(CharacterStatus(rawString: "Dead"), .dead)
    }

    func test_unknownCaseInsensitive() {
        XCTAssertEqual(CharacterStatus(rawString: "unknown"), .unknown)
        XCTAssertEqual(CharacterStatus(rawString: "Unknown"), .unknown)
    }

    func test_unrecognizedReturnsNil() {
        XCTAssertNil(CharacterStatus(rawString: "ancient"))
        XCTAssertNil(CharacterStatus(rawString: ""))
    }
}

// MARK: - PageResult

final class PageResultTests: XCTestCase {
    func test_equality() {
        let a = PageResult(items: [1, 2, 3], page: 1, totalPages: 5, hasNext: true)
        let b = PageResult(items: [1, 2, 3], page: 1, totalPages: 5, hasNext: true)
        XCTAssertEqual(a, b)
    }

    func test_inequality_items() {
        let a = PageResult(items: [1, 2], page: 1, totalPages: 1, hasNext: false)
        let b = PageResult(items: [1, 3], page: 1, totalPages: 1, hasNext: false)
        XCTAssertNotEqual(a, b)
    }

    func test_inequality_hasNext() {
        let a = PageResult(items: [1], page: 1, totalPages: 1, hasNext: true)
        let b = PageResult(items: [1], page: 1, totalPages: 1, hasNext: false)
        XCTAssertNotEqual(a, b)
    }
}

// MARK: - Character

final class CharacterTests: XCTestCase {
    func test_equality() {
        let a = Character(
            id: 1, name: "Rick", status: "Alive", species: "Human",
            type: "", gender: "Male", image: "https://example.com/1.jpeg",
            originName: "Earth", originUrl: "https://example.com/earth",
            locationName: "Earth", locationUrl: "https://example.com/earth",
            episodeIds: [1, 2]
        )
        let b = a
        XCTAssertEqual(a, b)
    }

    func test_identifiable() {
        let a = Character(
            id: 1, name: "Rick", status: "Alive", species: "Human",
            type: "", gender: "Male", image: "https://example.com/1.jpeg",
            originName: "Earth", originUrl: "",
            locationName: "Earth", locationUrl: "",
            episodeIds: []
        )
        let b = Character(
            id: 2, name: "Morty", status: "Alive", species: "Human",
            type: "", gender: "Male", image: "https://example.com/2.jpeg",
            originName: "Earth", originUrl: "",
            locationName: "Earth", locationUrl: "",
            episodeIds: []
        )
        XCTAssertNotEqual(a.id, b.id)
    }
}
