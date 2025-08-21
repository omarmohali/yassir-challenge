import Foundation

protocol CharactersAPIServiceProtocol {
  func getCharacters(filters: [FilterDto]) async throws -> CharactersResponseDto
}

class CharactersAPIService: CharactersAPIServiceProtocol {
  
  private let service: Service
  
  init(service: Service) {
    self.service = service
  }
  
  func getCharacters(filters: [FilterDto] = []) async throws -> CharactersResponseDto {
    let queryItems: [URLQueryItem] = [
//        filters.status == nil ? nil : .init(name: "status", value: filters.status?.rawValue),
    ].compactMap { $0 }
    
    var urlComponents = URLComponents(string: "\(service.baseURL.absoluteString)/character/")
    if !queryItems.isEmpty {
        urlComponents?.queryItems = queryItems
    }
    
    guard let url = urlComponents?.url else { throw NSError() }
    
    let request = URLRequest(url: url)
    
    let (data, _) = try await service.session.data(for: request)
    let response = try JSONDecoder().decode(CharactersResponseDto.self, from: data)
    return response
  }
}
