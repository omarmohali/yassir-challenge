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
    var queryItems: [URLQueryItem] = [
        URLQueryItem(name: "count", value: "20"),
        URLQueryItem(name: "page", value: "\(page)")
    ]
    
    if let filter = filter {
        queryItems.append(URLQueryItem(name: "status", value: filter.rawValue))
    }
    
    let data = try await networkClient.get(path: "/character/", queryItems: queryItems)
    let response = try JSONDecoder().decode(CharactersResponseDto.self, from: data)
    return response
  }
}
