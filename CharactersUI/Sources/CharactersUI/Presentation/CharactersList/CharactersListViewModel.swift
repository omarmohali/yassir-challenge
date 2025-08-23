class CharactersListViewModel {
  enum State: Equatable {
    case loading
    case loaded([Character])
    case error(message: String)
  }
  
  private let charactersLoader: CharactersLoaderProtocol
  
  var state: State = .loading
  var filter: Filter?
  var stateDidChange: ((Bool) -> Void)?
  
  private var page = 1
  
  init(charactersLoader: CharactersLoaderProtocol) {
    self.charactersLoader = charactersLoader
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
  func retry() {
    state = .loading
    stateDidChange?(false)
    loadCharacters()
  }
  
  @MainActor private func loadCharacters() {
    charactersLoader.getCharacters(for: page, filter: filter) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .success(characters):
        if page == 1 {
          self.state = .loaded(characters)
          self.stateDidChange?(true)
        } else {
          guard case let .loaded(oldCharacters) = self.state else { return }
          var newCharacters = oldCharacters
          newCharacters.append(contentsOf: characters)
          self.state = .loaded(newCharacters)
          self.stateDidChange?(false)
        }
      case .failure:
        state = .error(message: LocalizedString.Generic.somethingWentWrong)
        self.stateDidChange?(false)
      }
    }
  }
}
