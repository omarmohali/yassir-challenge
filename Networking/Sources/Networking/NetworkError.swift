import Foundation

public enum NetworkError: Error, Equatable {
  public struct HttpError: Equatable, Error {
    public let statusCode: Int
    public let data: Data
  }
  
  case httpError(HttpError)
  case invalidUrl
}
