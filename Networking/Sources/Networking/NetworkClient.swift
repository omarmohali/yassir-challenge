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
    var urlComponents = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false)
    
    urlComponents?.queryItems = queryItems.isEmpty ? nil : queryItems
    
    guard let url = urlComponents?.url else {
      throw NetworkError.invalidUrl
    }
    
    let request = URLRequest(url: url)
    
    let (data, response) = try await session.data(for: request)
    if let httpResponse = response as? HTTPURLResponse,
       httpResponse.statusCode >= 400 && httpResponse.statusCode <= 599 {
      throw NetworkError.httpError(
        .init(statusCode: httpResponse.statusCode, data: data)
      )
    } else {
      return data
    }
  }
}
