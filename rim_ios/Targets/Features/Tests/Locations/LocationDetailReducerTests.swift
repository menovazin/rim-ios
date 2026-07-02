import ComposableArchitecture
import XCTest
import Models

@testable import Features

final class LocationDetailReducerTests: XCTestCase {
    @MainActor
    func test_state_holdsPassedLocation() async {
        let location = Location(
            id: 1, name: "Earth (C-137)", type: "Planet",
            dimension: "Dimension C-137",
            residentIds: [1, 2, 3]
        )
        let store = TestStore(initialState: LocationDetailReducer.State(location: location)) {
            LocationDetailReducer()
        }

        // The reducer is effect-free; state simply carries the entity.
        XCTAssertEqual(store.state.location, location)
        await store.finish()
    }
}
