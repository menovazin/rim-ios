import XCTest
@testable import Networking

final class NetworkingTests: XCTestCase {
    func test_moduleName() {
        XCTAssertEqual(NetworkingModule.name, "Networking")
    }
}

// MARK: - DTO Decoding

final class CharacterDTODecodingTests: XCTestCase {
    private let sampleJSON = """
    {
        "info": {
            "count": 826,
            "pages": 42,
            "next": "https://alpha.syazy.com/api/character?page=2",
            "prev": null
        },
        "results": [
            {
                "id": 1,
                "name": "Rick Sanchez",
                "status": "Alive",
                "species": "Human",
                "type": "",
                "gender": "Male",
                "image": "https://alpha.syazy.com/api/character/avatar/1.jpeg",
                "origin": {
                    "name": "Earth",
                    "url": "https://alpha.syazy.com/api/location/1"
                },
                "location": {
                    "name": "Earth",
                    "url": "https://alpha.syazy.com/api/location/20"
                },
                "episode": [
                    "https://alpha.syazy.com/api/episode/1",
                    "https://alpha.syazy.com/api/episode/2"
                ],
                "url": "https://alpha.syazy.com/api/character/1",
                "created": "2017-11-04T18:48:46.250Z"
            }
        ]
    }
    """.data(using: .utf8)!

    func test_decodesCharacterResponse() throws {
        let decoded = try JSONDecoder().decode(CharacterResponseDTO.self, from: sampleJSON)

        XCTAssertEqual(decoded.info.pages, 42)
        XCTAssertEqual(decoded.info.next, "https://alpha.syazy.com/api/character?page=2")
        XCTAssertEqual(decoded.results.count, 1)

        let character = decoded.results[0]
        XCTAssertEqual(character.id, 1)
        XCTAssertEqual(character.name, "Rick Sanchez")
        XCTAssertEqual(character.status, "Alive")
        XCTAssertEqual(character.species, "Human")
        XCTAssertEqual(character.type, "")
        XCTAssertEqual(character.gender, "Male")
        XCTAssertEqual(character.origin.name, "Earth")
        XCTAssertEqual(character.location.name, "Earth")
        XCTAssertEqual(character.episode.count, 2)
        XCTAssertEqual(character.url, "https://alpha.syazy.com/api/character/1")
        XCTAssertEqual(character.created, "2017-11-04T18:48:46.250Z")
    }

    func test_decodesLastPageWithNullNext() throws {
        let lastPageJSON = """
        {
            "info": { "count": 826, "pages": 42, "next": null, "prev": "..." },
            "results": []
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(CharacterResponseDTO.self, from: lastPageJSON)
        XCTAssertNil(decoded.info.next)
        XCTAssertEqual(decoded.info.pages, 42)
        XCTAssertTrue(decoded.results.isEmpty)
    }

    func test_decodesMultipleCharacters() throws {
        let multiJSON = """
        {
            "info": { "count": 826, "pages": 42, "next": "...", "prev": null },
            "results": [
                { "id": 1, "name": "Rick", "status": "Alive", "species": "Human",
                  "type": "", "gender": "Male", "image": "https://img/1.jpeg",
                  "origin": {"name":"Earth","url":""}, "location": {"name":"Earth","url":""},
                  "episode":[], "url":"", "created":"" },
                { "id": 2, "name": "Morty", "status": "Alive", "species": "Human",
                  "type": "", "gender": "Male", "image": "https://img/2.jpeg",
                  "origin": {"name":"Earth","url":""}, "location": {"name":"Earth","url":""},
                  "episode":[], "url":"", "created":"" }
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(CharacterResponseDTO.self, from: multiJSON)
        XCTAssertEqual(decoded.results.count, 2)
        XCTAssertEqual(decoded.results[0].id, 1)
        XCTAssertEqual(decoded.results[1].id, 2)
    }
}
