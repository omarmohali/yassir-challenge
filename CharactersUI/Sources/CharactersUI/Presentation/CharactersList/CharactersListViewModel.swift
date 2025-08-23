import SwiftUI

class CharactersListViewModel {
  
  enum State {
    case loading
    case loaded([Character])
    case error(message: String)
  }
  
  private let repository: CharactersRepositoryProtocol
  
  var state: State = .loading
  var filter: Filter?
  var stateDidChange: ((Bool) -> Void)?
  
  private var page = 1
  
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
  func retry() {
    state = .loading
    stateDidChange?(false)
    loadCharacters()
  }
  
  @MainActor
  private func loadCharacters() {
    Task {
      do {
        let characters = try await repository.getCharacters(for: page, filter: filter)
        await MainActor.run {
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
        }
      } catch {
        state = .error(message: "Something went wrong")
        self.stateDidChange?(false)
      }
    }
  }
}
