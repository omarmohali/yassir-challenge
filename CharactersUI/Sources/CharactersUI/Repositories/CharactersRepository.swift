import Foundation
import CharactersAPI

protocol CharactersRepositoryProtocol {
  func getCharacters(for page: Int, filter: Filter?) async throws -> [Character]
}

class CharactersRepository: CharactersRepositoryProtocol {
  private let api: CharactersAPIProtocol
  init(api: CharactersAPIProtocol) {
    self.api = api
  }
  
  func getCharacters(for page: Int, filter: Filter?) async throws -> [Character] {
    let apiResponse = try await api.getCharacters(page: page, filter: filter.map(FilterDto.init))
    return apiResponse.results.map(Character.init)
  }
}

protocol CharactersLoaderProtocol {
  @MainActor
  func getCharacters(for page: Int, filter: Filter?, completion: @escaping (Result<[Character], any Error>) -> Void)
}

class CharactersLoader: CharactersLoaderProtocol {
  private let api: CharactersAPIProtocol
  init(api: CharactersAPIProtocol) {
    self.api = api
  }
  
  @MainActor
  func getCharacters(for page: Int, filter: Filter?, completion: @escaping (Result<[Character], any Error>) -> Void) {
    Task {
      let result: Result<[Character], any Error>
      do {
        let apiResponse = try await api.getCharacters(page: page, filter: filter.map(FilterDto.init))
        result = .success(apiResponse.results.map(Character.init))
      } catch {
        result = .failure(error)
      }
      
      await MainActor.run {
        completion(result)
      }
    }
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
      status: .init(dto.status),
      gender: dto.gender
    )
  }
}

extension Character.Status {
  init(_ string: String) {
    switch string.lowercased() {
    case "alive":
      self = .alive
    case "dead":
      self = .dead
    default:
      self = .unknown
    }
  }
}
