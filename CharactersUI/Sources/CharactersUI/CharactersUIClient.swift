import UIKit
import SwiftUI
import CharactersAPI

public class CharactersUIClient {
  private let api: CharactersAPIProtocol
  
  public init(api: CharactersAPIProtocol) {
    self.api = api
  }
  
  @MainActor
  public func charactersUINavigationController() -> UINavigationController {
    let loader = CharactersLoader(api: api)
    let viewModel = CharactersListViewModel(charactersLoader: loader)
    let nc = UINavigationController()
    
    let listVC = CharactersListViewController(viewModel: viewModel) { character in
      let detailsView = CharacterDetailsView(character: character) {
        nc.popViewController(animated: true)
        nc.setNavigationBarHidden(false, animated: true)
      }
      nc.setNavigationBarHidden(true, animated: true)
      nc.pushViewController(UIHostingController(rootView: detailsView), animated: true)
    }
    
    nc.viewControllers = [listVC]
    return nc
  }
}
