import ComposableArchitecture
import Foundation
import Models

/// Reducer for the Location Detail screen.
///
/// State is effect-free: the `Location` is passed in from the list and the
/// view renders directly from it. No `APIClient` dependency or refetch.
/// Resident avatars are derived from `location.residentIds` — pure Flutter parity.
@Reducer
public struct LocationDetailReducer {
    @ObservableState
    public struct State: Equatable, Sendable {
        public let location: Location

        public init(location: Location) {
            self.location = location
        }
    }

    public enum Action: Equatable, Sendable {}

    public init() {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
