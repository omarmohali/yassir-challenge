import Foundation

struct CharactersResponseDto: Decodable {
    public let results: [CharacterDto]
}

struct CharacterDto: Decodable, Equatable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let image: URL
}

