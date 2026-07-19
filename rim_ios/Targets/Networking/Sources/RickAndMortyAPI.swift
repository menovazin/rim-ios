import Foundation
import Models

/// Live Rick & Morty HTTP surface: `URLSession` fetch, DTO decode, map to domain models.
///
/// No TCA / dependency injection here — Features wraps this behind `@DependencyClient`.
public enum RickAndMortyAPI {
    private static let baseURL = URL(string: ApiConstants.baseUrl)!

    public static func fetchCharacters(page: Int) async throws -> PageResult<Character> {
        let decoded: CharacterResponseDTO = try await fetchPage(path: "character", page: page)
        let characters = decoded.results.map { dto in
            Character(
                id: dto.id,
                name: dto.name,
                status: dto.status,
                species: dto.species,
                type: dto.type,
                gender: dto.gender,
                image: RimAvatarURL.fixing(dto.image),
                originName: dto.origin.name,
                originUrl: dto.origin.url,
                locationName: dto.location.name,
                locationUrl: dto.location.url,
                episodeIds: dto.episode.compactMap(idFromResourceURL)
            )
        }
        return PageResult(
            items: characters,
            page: page,
            totalPages: decoded.info.pages,
            hasNext: decoded.info.next != nil
        )
    }

    public static func fetchEpisodes(page: Int) async throws -> PageResult<Episode> {
        let decoded: EpisodeResponseDTO = try await fetchPage(path: "episode", page: page)
        let episodes = decoded.results.map { dto in
            Episode(
                id: dto.id,
                name: dto.name,
                episodeCode: dto.episode,
                airDate: dto.airDate,
                characterIds: dto.characters.compactMap(idFromResourceURL)
            )
        }
        return PageResult(
            items: episodes,
            page: page,
            totalPages: decoded.info.pages,
            hasNext: decoded.info.next != nil
        )
    }

    public static func fetchLocations(page: Int) async throws -> PageResult<Location> {
        let decoded: LocationResponseDTO = try await fetchPage(path: "location", page: page)
        let locations = decoded.results.map { dto in
            Location(
                id: dto.id,
                name: dto.name,
                type: dto.type,
                dimension: dto.dimension,
                residentIds: dto.residents.compactMap(idFromResourceURL)
            )
        }
        return PageResult(
            items: locations,
            page: page,
            totalPages: decoded.info.pages,
            hasNext: decoded.info.next != nil
        )
    }

    // MARK: - Private

    private static func fetchPage<DTO: Decodable>(path: String, page: Int) async throws -> DTO {
        let url = baseURL.appendingPathComponent(path)
            .appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(DTO.self, from: data)
    }

    private static func idFromResourceURL(_ urlString: String) -> Int? {
        guard let last = URL(string: urlString)?.lastPathComponent,
              let id = Int(last) else { return nil }
        return id
    }
}
