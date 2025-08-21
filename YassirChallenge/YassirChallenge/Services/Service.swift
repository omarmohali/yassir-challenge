import Foundation

class Service {
  private(set) var baseURL: URL
  private(set) var session: URLSession

  init(
      session: URLSession = .shared,
      baseURL: URL
  ) {
      self.session = session
      self.baseURL = baseURL
  }
}
