import Foundation

public protocol NetworkClientProtocol {
  func get(path: String, queryItems: [URLQueryItem]) async throws -> Data
}

public class NetworkClient: NetworkClientProtocol {
  private(set) var baseURL: URL
  private(set) var session: URLSession

  public init(
      session: URLSession = .shared,
      baseURL: URL
  ) {
      self.session = session
      self.baseURL = baseURL
  }
  
  public func get(path: String, queryItems: [URLQueryItem]) async throws -> Data {
    var urlComponents = URLComponents(string: "\(baseURL.absoluteString)\(path)")
    if !queryItems.isEmpty {
        urlComponents?.queryItems = queryItems
    }
    
    guard let url = urlComponents?.url else { throw NSError() }
    
    let request = URLRequest(url: url)
    
    let (data, response) = try await session.data(for: request)
    if let httpResponse = response as? HTTPURLResponse,
       httpResponse.statusCode >= 400 && httpResponse.statusCode <= 599 {
      throw NetworkError(statusCode: httpResponse.statusCode, data: data)
    } else {
      return data
    }
  }
}
