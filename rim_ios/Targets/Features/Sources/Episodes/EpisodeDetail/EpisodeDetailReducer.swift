import ComposableArchitecture
import Foundation
import Models

/// Reducer for the Episode Detail screen.
///
/// State is effect-free: the `Episode` is passed in from the list and the
/// view renders directly from it. No `APIClient` dependency or refetch.
/// Resident avatars are derived from `episode.characterIds` — pure Flutter parity.
@Reducer
public struct EpisodeDetailReducer {
    @ObservableState
    public struct State: Equatable, Sendable {
        public let episode: Episode

        public init(episode: Episode) {
            self.episode = episode
        }
    }

    public enum Action: Equatable, Sendable {}

    public init() {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
