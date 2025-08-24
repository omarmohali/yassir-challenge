@MainActor
class CharactersListViewModel {
  enum State: Equatable {
    case loading
    case loaded([Character], isFirstPage: Bool)
    case error(message: String)
  }
  
  private let charactersLoader: CharactersLoaderProtocol
  
  private(set) var state: State = .loading {
    didSet {
      stateDidChange?()
    }
  }
  
  private var filter: Filter?
  var stateDidChange: (() -> Void)?
  
  private var page = 1
  
  init(charactersLoader: CharactersLoaderProtocol) {
    self.charactersLoader = charactersLoader
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
  
  func retry() {
    state = .loading
    loadCharacters()
  }
  
  private func loadCharacters() {
    charactersLoader.getCharacters(for: page, filter: filter) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .success(characters):
        if page == 1 {
          self.state = .loaded(characters, isFirstPage: true)
        } else {
          guard case let .loaded(oldCharacters, _) = self.state else { return }
          var newCharacters = oldCharacters
          newCharacters.append(contentsOf: characters)
          self.state = .loaded(newCharacters, isFirstPage: false)
        }
      case .failure:
        state = .error(message: LocalizedString.Generic.somethingWentWrong)
      }
    }
  }
}
