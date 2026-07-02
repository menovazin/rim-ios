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

// MARK: - Live implementation

extension APIClient {
    public static let live: APIClient = {
        let baseURL = URL(string: "https://rickandmortyapi.com/api")!
        return APIClient(
            fetchCharacters: { page in
                let url = baseURL.appendingPathComponent("character")
                    .appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let http = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard (200..<300).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                let decoded = try JSONDecoder().decode(CharacterResponseDTO.self, from: data)
                let characters = decoded.results.map { dto in
                    Character(
                        id: dto.id,
                        name: dto.name,
                        status: dto.status,
                        species: dto.species,
                        type: dto.type,
                        gender: dto.gender,
                        image: dto.image,
                        originName: dto.origin.name,
                        originUrl: dto.origin.url,
                        locationName: dto.location.name,
                        locationUrl: dto.location.url,
                        episodeIds: dto.episode.compactMap { urlString in
                            guard let last = URL(string: urlString)?.lastPathComponent,
                                  let id = Int(last) else { return nil }
                            return id
                        }
                    )
                }
                return PageResult(
                    items: characters,
                    page: page,
                    totalPages: decoded.info.pages,
                    hasNext: decoded.info.next != nil
                )
            },
            fetchEpisodes: { page in
                let url = baseURL.appendingPathComponent("episode")
                    .appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let http = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard (200..<300).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                let decoded = try JSONDecoder().decode(EpisodeResponseDTO.self, from: data)
                let episodes = decoded.results.map { dto in
                    Episode(
                        id: dto.id,
                        name: dto.name,
                        episodeCode: dto.episode,
                        airDate: dto.airDate,
                        characterIds: dto.characters.compactMap { urlString in
                            guard let last = URL(string: urlString)?.lastPathComponent,
                                  let id = Int(last) else { return nil }
                            return id
                        }
                    )
                }
                return PageResult(
                    items: episodes,
                    page: page,
                    totalPages: decoded.info.pages,
                    hasNext: decoded.info.next != nil
                )
            },
            fetchLocations: { page in
                let url = baseURL.appendingPathComponent("location")
                    .appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let http = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard (200..<300).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                let decoded = try JSONDecoder().decode(LocationResponseDTO.self, from: data)
                let locations = decoded.results.map { dto in
                    Location(
                        id: dto.id,
                        name: dto.name,
                        type: dto.type,
                        dimension: dto.dimension,
                        residentIds: dto.residents.compactMap { urlString in
                            guard let last = URL(string: urlString)?.lastPathComponent,
                                  let id = Int(last) else { return nil }
                            return id
                        }
                    )
                }
                return PageResult(
                    items: locations,
                    page: page,
                    totalPages: decoded.info.pages,
                    hasNext: decoded.info.next != nil
                )
            }
        )
    }()
}
