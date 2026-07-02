import ComposableArchitecture
import XCTest
import Models

@testable import Features

final class CharacterDetailReducerTests: XCTestCase {
    @MainActor
    func test_state_holdsPassedCharacter() async {
        let character = Character(
            id: 1, name: "Rick Sanchez", status: "Alive", species: "Human",
            type: "", gender: "Male", image: "https://example.com/1.jpeg",
            originName: "Earth", originUrl: "",
            locationName: "Earth", locationUrl: "",
            episodeIds: [1, 2, 3]
        )
        let store = TestStore(initialState: CharacterDetailReducer.State(character: character)) {
            CharacterDetailReducer()
        }

        // The reducer is effect-free; state simply carries the entity.
        XCTAssertEqual(store.state.character, character)
        await store.finish()
    }
}
