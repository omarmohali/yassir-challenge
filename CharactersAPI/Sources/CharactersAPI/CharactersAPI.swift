import Foundation
import Networking

public protocol CharactersAPIProtocol {
  func getCharacters(page: Int, filter: FilterDto?) async throws -> CharactersResponseDto
}

public class CharactersAPI: CharactersAPIProtocol {
  private let networkClient: NetworkClientProtocol
  
  public init(networkClient: NetworkClientProtocol) {
    self.networkClient = networkClient
  }
  
  public func getCharacters(page: Int, filter: FilterDto? = nil) async throws -> CharactersResponseDto {
    let queryItems: [URLQueryItem] = [
      .init(name: "count", value: "20"),
      .init(name: "page", value: "\(page)"),
      filter == nil ? nil : .init(name: "status", value: filter?.rawValue),
    ].compactMap { $0 }
    
    let data = try await networkClient.get(path: "/character/", queryItems: queryItems)
    let response = try JSONDecoder().decode(CharactersResponseDto.self, from: data)
    return response
  }
}
