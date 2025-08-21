import Foundation

public struct NetworkError: Error, Equatable {
  public let statusCode: Int
  public let data: Data
}
