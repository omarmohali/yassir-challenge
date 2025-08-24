import UIKit
import SwiftUI

class CharactersListViewController: UITableViewController {
  enum Section {
      case main
  }
  
  private static let cellIdentifier = "CharacterCell"
  private let viewModel: CharactersListViewModel
  private let didSelectCharacter: (Character) -> Void
  private var dataSource: UITableViewDiffableDataSource<Section, Character>!
  
  init(viewModel: CharactersListViewModel, didSelectCharacter: @escaping (Character) -> Void) {
    self.viewModel = viewModel
    self.didSelectCharacter = didSelectCharacter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = LocalizedString.CharactersList.Navigation.title
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    viewModel.stateDidChange = { [weak self] in
      Task { @MainActor in
        self?.bindView()
      }
    }
    
    tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    tableView.separatorStyle = .none
    
    dataSource = UITableViewDiffableDataSource<Section, Character>(tableView: tableView) { tableView, indexPath, character in
      let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath) as! CharacterTableViewCell
      cell.selectionStyle = .none
      cell.set(character: character, parent: self)
      return cell
    }
    bindView()
    viewModel.didLoad()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if let character = dataSource.itemIdentifier(for: indexPath) {
          didSelectCharacter(character)
      }
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return 50
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == (viewModel.state.characters.count - 1) {
      viewModel.loadMore()
    }
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let filtersView = FiltersView() { [weak self] filter in
      self?.viewModel.applyFilter(filter: filter)
    }
    return UIHostingController(rootView: filtersView).view
  }
  
  private func bindView() {
    switch viewModel.state {
    case let .loaded(characters, isFirstPage):
      tableView.backgroundView = nil
      applySnapshot(characters: characters, scrollToTop: isFirstPage)
    case .loading:
      setLoadingView()
    case let .error(message):
      setErrorView(message: message)
    }
  }
  
  private func applySnapshot(characters: [Character], scrollToTop: Bool) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Character>()
    snapshot.appendSections([.main])
    snapshot.appendItems(characters, toSection: .main)
        
    dataSource.apply(snapshot, animatingDifferences: !scrollToTop) { [weak self] in
      guard scrollToTop, let self = self else { return }
      if !characters.isEmpty {
            self.tableView.scrollToRow(
                at: IndexPath(row: 0, section: 0),
                at: .top,
                animated: false
            )
        }
    }
  }
  
  private func setLoadingView() {
    self.tableView.backgroundView = UIHostingController(rootView: ProgressView()).view
  }
  
  private func setErrorView(message: String) {
    let errorView = ErrorView(message: message) { [weak self] in
      self?.viewModel.retry()
    }
    tableView.backgroundView = UIHostingController(rootView: errorView).view
  }
}


extension CharactersListViewModel.State {
  var characters: [Character] {
    switch self {
    case let .loaded(characters, _):
      characters
    case .error, .loading:
      []
    }
  }
}
