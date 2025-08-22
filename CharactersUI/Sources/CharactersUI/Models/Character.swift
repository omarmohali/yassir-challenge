import Foundation

struct Character: Hashable, Sendable {
  let id: Int
  let name: String
  let imageUrl: URL
  let species: String
  let status: String
  let gender: String
}
