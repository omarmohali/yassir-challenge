import SwiftUI

class CharactersListViewModel: ObservableObject {
  private let repository: CharactersRepositoryProtocol
  
  var characters: [Character] = []
  var filter: Filter?
  var charactersDidChange: (@Sendable (Bool) -> Void)?
  private var page = 1
  @Published var isLoading = false
  
  init(repository: CharactersRepositoryProtocol) {
    self.repository = repository
  }
  
  @MainActor
  func didLoad() {
    loadCharacters()
  }
  
  @MainActor
  func loadMore() {
    page += 1
    loadCharacters()
  }
  
  @MainActor
  func applyFilter(filter: Filter?) {
    self.filter = filter
    page = 1
    loadCharacters()
  }
  
  @MainActor
  private func loadCharacters() {
    Task {
      isLoading = true
      let characters = try await repository.getCharacters(for: page, filter: filter)
      isLoading = false
      await MainActor.run {
        if page == 1 {
          self.characters = characters
          self.charactersDidChange?(true)
        } else {
          self.characters.append(contentsOf: characters)
          self.charactersDidChange?(false)
        }
        
      }
    }
  }
}
