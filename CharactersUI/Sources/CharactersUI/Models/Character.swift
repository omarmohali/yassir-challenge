import Foundation

struct Character: Hashable, Sendable {
  enum Status {
    case alive
    case dead
    case unknown
  }
  
  let id: Int
  let name: String
  let imageUrl: URL
  let species: String
  let status: Status
  let gender: String
}
