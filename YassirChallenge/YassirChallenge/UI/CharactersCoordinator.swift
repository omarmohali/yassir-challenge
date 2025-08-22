import UIKit
import SwiftUI
import Networking
import CharactersAPI

class CharactersCoordinator {
  func getCharactersController() -> UIViewController {
    let networkClient = NetworkClient(baseURL: URL(string: "https://rickandmortyapi.com/api")!)
    let apiService = CharactersAPI(networkClient: networkClient)
    let repository = CharactersRepository(api: apiService)
    let viewModel = CharactersListViewModel(repository: repository)
    var nc: UINavigationController?
    let viewController = CharactersListViewController(viewModel: viewModel) { character in
      nc?.pushViewController(UIHostingController(rootView: CharacterDetailsView(character: character)), animated: true)
    }
    nc = UINavigationController(rootViewController: viewController)
    return nc!
  }
}
