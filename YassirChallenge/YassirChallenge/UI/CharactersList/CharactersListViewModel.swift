class CharactersListViewModel {
  private let repository: CharactersRepositoryProtocol
  
  var characters: [Character] = []
  var charactersDidChange: (() -> Void)?
  init(repository: CharactersRepositoryProtocol) {
    self.repository = repository
  }
  
  func didLoad() {
    Task {
      let characters = try await repository.getCharacters(for: 1, filter: nil)
      await MainActor.run {
        self.characters = characters
        self.charactersDidChange?()
      }
    }
  }
}
