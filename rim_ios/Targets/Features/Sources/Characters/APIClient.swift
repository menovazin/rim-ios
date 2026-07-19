import ComposableArchitecture
import Foundation
import Models
import Networking

// MARK: - APIClient dependency

/// Fetches paginated domain objects from the Rick & Morty REST API.
///
/// `@DependencyClient` with `unimplemented` defaults — tests inject via
/// `APIClient.test(...)` for deterministic pages with no network.
@DependencyClient
public struct APIClient: Sendable {
    var fetchCharacters: @Sendable (Int) async throws -> PageResult<Character>
    var fetchEpisodes: @Sendable (Int) async throws -> PageResult<Episode>
    var fetchLocations: @Sendable (Int) async throws -> PageResult<Location>
}

extension APIClient: DependencyKey {
    public static let liveValue = APIClient.live
}

extension APIClient: TestDependencyKey {
    public static let testValue = APIClient()
    public static let previewValue = APIClient(
        fetchCharacters: { _ in
            PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
        },
        fetchEpisodes: { _ in
            PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
        },
        fetchLocations: { _ in
            PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
        }
    )
}

extension DependencyValues {
    public var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

// MARK: - In-memory test helpers

extension APIClient {
    /// Returns a deterministic test client that serves `pages` in order.
    ///
    /// Each call to `fetchCharacters(page:)` pops the next entry.
    /// If pages are exhausted, it returns an empty page with `hasNext: false`.
    public static func test(pages: [PageResult<Character>]) -> APIClient {
        var iterator = pages.makeIterator()
        return APIClient(
            fetchCharacters: { _ in
                iterator.next() ?? PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
            },
            fetchEpisodes: { _ in
                PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
            },
            fetchLocations: { _ in
                PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
            }
        )
    }

    /// Returns a deterministic test client that serves episode `pages` in order.
    public static func test(episodes pages: [PageResult<Episode>]) -> APIClient {
        var iterator = pages.makeIterator()
        return APIClient(
            fetchCharacters: { _ in
                PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
            },
            fetchEpisodes: { _ in
                iterator.next() ?? PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
            },
            fetchLocations: { _ in
                PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
            }
        )
    }

    /// Returns a deterministic test client that serves location `pages` in order.
    public static func test(locations pages: [PageResult<Location>]) -> APIClient {
        var iterator = pages.makeIterator()
        return APIClient(
            fetchCharacters: { _ in
                PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
            },
            fetchEpisodes: { _ in
                PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
            },
            fetchLocations: { _ in
                iterator.next() ?? PageResult(items: [], page: 1, totalPages: 1, hasNext: false)
            }
        )
    }

    /// Returns a test client that always throws the given error.
    public static func failing(with error: Error = URLError(.notConnectedToInternet)) -> APIClient {
        APIClient(
            fetchCharacters: { _ in throw error },
            fetchEpisodes: { _ in throw error },
            fetchLocations: { _ in throw error }
        )
    }

    /// Returns a test client for episodes that always throws the given error.
    public static func failingEpisodes(with error: Error = URLError(.notConnectedToInternet)) -> APIClient {
        APIClient(
            fetchCharacters: { _ in throw error },
            fetchEpisodes: { _ in throw error },
            fetchLocations: { _ in throw error }
        )
    }

    /// Returns a test client for locations that always throws the given error.
    public static func failingLocations(with error: Error = URLError(.notConnectedToInternet)) -> APIClient {
        APIClient(
            fetchCharacters: { _ in throw error },
            fetchEpisodes: { _ in throw error },
            fetchLocations: { _ in throw error }
        )
    }
}

// MARK: - Live implementation (delegates to Networking)

extension APIClient {
    public static let live = APIClient(
        fetchCharacters: { page in
            try await RickAndMortyAPI.fetchCharacters(page: page)
        },
        fetchEpisodes: { page in
            try await RickAndMortyAPI.fetchEpisodes(page: page)
        },
        fetchLocations: { page in
            try await RickAndMortyAPI.fetchLocations(page: page)
        }
    )
}
