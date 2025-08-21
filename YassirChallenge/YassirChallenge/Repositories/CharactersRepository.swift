import Foundation

protocol CharactersRepositoryProtocol {
  func getCharacters(for page: Int, filters: [Filter]) async throws -> [Character]
}

class CharactersRepository: CharactersRepositoryProtocol {
  
  private let service: CharactersAPIServiceProtocol
  init(service: CharactersAPIServiceProtocol) {
    self.service = service
  }
  
  func getCharacters(for page: Int, filters: [Filter]) async throws -> [Character] {
    let apiResponse = try await service.getCharacters(filters: filters.map(FilterDto.init))
    return apiResponse.results.map(Character.init)
  }
}

extension FilterDto {
  init(filter: Filter) {
    switch filter {
    case .alive:
      self = .alive
    case .dead:
      self = .dead
    case .unknown:
      self = .unknown
    }
  }
}

extension Character {
  init(dto: CharacterDto) {
    self.init(
      id: dto.id,
      name: dto.name,
      imageUrl: dto.image,
      species: dto.species,
      status: dto.status,
      gender: dto.gender
    )
  }
}
