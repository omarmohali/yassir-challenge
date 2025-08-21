import Foundation
import Networking

protocol CharactersAPIServiceProtocol {
  func getCharacters(filters: [FilterDto]) async throws -> CharactersResponseDto
}

class CharactersAPIService: CharactersAPIServiceProtocol {
  
  private let networkClient: NetworkClientProtocol
  
  init(networkClient: NetworkClientProtocol) {
    self.networkClient = networkClient
  }
  
  func getCharacters(filters: [FilterDto] = []) async throws -> CharactersResponseDto {
    
    let queryItems: [URLQueryItem] = [
//        filters.status == nil ? nil : .init(name: "status", value: filters.status?.rawValue),
    ].compactMap { $0 }
    
    let data = try await networkClient.get(path: "/character/", queryItems: queryItems)
    let response = try JSONDecoder().decode(CharactersResponseDto.self, from: data)
    return response
  }
}
