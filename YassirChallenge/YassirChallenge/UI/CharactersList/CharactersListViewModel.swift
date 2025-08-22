class CharactersListViewModel {
  private let repository: CharactersRepositoryProtocol
  
  var characters: [Character] = []
  var filter: Filter?
  var charactersDidChange: ((_ scrollToTop: Bool) -> Void)?
  var page = 1
  init(repository: CharactersRepositoryProtocol) {
    self.repository = repository
  }
  
  func didLoad() {
    loadCharacters()
  }
  
  func loadMore() {
    page += 1
    loadCharacters()
  }
  
  func applyFilter(filter: Filter?) {
    self.filter = filter
    page = 1
    loadCharacters()
  }
  
  private func loadCharacters() {
    Task {
      let characters = try await repository.getCharacters(for: page, filter: filter)
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
