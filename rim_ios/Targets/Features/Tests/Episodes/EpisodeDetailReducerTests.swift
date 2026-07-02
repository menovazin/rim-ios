import ComposableArchitecture
import XCTest
import Models

@testable import Features

final class EpisodeDetailReducerTests: XCTestCase {
    @MainActor
    func test_state_holdsPassedEpisode() async {
        let episode = Episode(
            id: 1, name: "Pilot", episodeCode: "S01E01",
            airDate: "December 2, 2013",
            characterIds: [1, 2, 3]
        )
        let store = TestStore(initialState: EpisodeDetailReducer.State(episode: episode)) {
            EpisodeDetailReducer()
        }

        // The reducer is effect-free; state simply carries the entity.
        XCTAssertEqual(store.state.episode, episode)
        await store.finish()
    }
}
