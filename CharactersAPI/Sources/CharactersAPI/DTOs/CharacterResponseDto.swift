import Foundation

public struct CharactersResponseDto: Decodable, Equatable, Sendable {
    public let results: [CharacterDto]
}

public struct CharacterDto: Decodable, Equatable, Sendable {
    public let id: Int
    public let name: String
    public let status: String
    public let species: String
    public let gender: String
    public let image: URL
}
