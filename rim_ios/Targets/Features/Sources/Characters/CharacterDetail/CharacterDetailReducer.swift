import ComposableArchitecture
import Foundation
import Models

/// Reducer for the Character Detail screen.
///
/// State is effect-free: the `Character` is passed in from the grid and the
/// view renders directly from it. No `APIClient` dependency or refetch.
@Reducer
public struct CharacterDetailReducer {
    @ObservableState
    public struct State: Equatable, Sendable {
        public let character: Character

        public init(character: Character) {
            self.character = character
        }
    }

    public enum Action: Equatable, Sendable {}

    public init() {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
