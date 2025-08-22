import SwiftUI

class CharactersListViewModel {
  private let repository: CharactersRepositoryProtocol
  
  var characters: [Character] = []
  var filter: Filter?
  var charactersDidChange: (@Sendable (Bool) -> Void)?
  var page = 1
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
  
//  @MainActor
//  private func loadCharacters() {
//    Task {
//      let characters = try await repository.getCharacters(for: 1, filter: nil)
//    }
//  }
//  private func loadCharacters() {
//      Task {
//          // Step 1: Read main-actor-isolated values safely
//          let (currentPage, currentFilter) = await MainActor.run {
//              (self.page, self.filter)
//          }
//
//          do {
//              // Step 2: Perform async repository call off the main actor
//              let newCharacters = try await repository.getCharacters(for: currentPage, filter: currentFilter)
//              
//              // Step 3: Update main-actor-isolated state safely
//              await MainActor.run {
//                  if currentPage == 1 {
//                      self.characters = newCharacters
//                      self.charactersDidChange?(true)
//                  } else {
//                      self.characters.append(contentsOf: newCharacters)
//                      self.charactersDidChange?(false)
//                  }
//              }
//          } catch {
//              print("Failed to load characters:", error)
//          }
//      }
//  }
  
  @MainActor
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
