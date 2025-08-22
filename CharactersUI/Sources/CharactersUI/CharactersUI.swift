import UIKit
import SwiftUI
import CharactersAPI

public class CharactersUIClient {
  private let api: CharactersAPIProtocol
  
  public init(api: CharactersAPIProtocol) {
    self.api = api
  }
  
  @MainActor public func charactersUINavigationController() -> UINavigationController {
    let repository = CharactersRepository(api: api)
    let viewModel = CharactersListViewModel(repository: repository)
    var nc: UINavigationController?
    let viewController = CharactersListViewController(viewModel: viewModel) { character in
      let characterDetailsView = CharacterDetailsView(character: character) {
        nc?.popViewController(animated: true)
        nc?.setNavigationBarHidden(false, animated: true)
      }
      nc?.setNavigationBarHidden(true, animated: true)
      nc?.pushViewController(UIHostingController(rootView: characterDetailsView), animated: true)
    }
    nc = UINavigationController(rootViewController: viewController)
    return nc!
  }
}
