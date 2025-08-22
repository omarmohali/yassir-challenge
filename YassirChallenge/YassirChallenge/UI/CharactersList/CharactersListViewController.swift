import UIKit
import SwiftUI

class CharactersListViewController: UITableViewController {
  enum Section {
      case main
  }
  
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
    navigationItem.title = "Characters"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    viewModel.charactersDidChange = { [weak self] scrollToTop in
      self?.applySnapshot(scrollToTop: scrollToTop)
    }
    
    tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: "CharacterCell")
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
    
    dataSource = UITableViewDiffableDataSource<Section, Character>(tableView: tableView) { tableView, indexPath, character in
      let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as! CharacterTableViewCell
      cell.set(character: character, parent: self)
      return cell
    }
    
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
    if indexPath.row == (viewModel.characters.count - 1) {
      viewModel.loadMore()
    }
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let filtersView = FiltersView() { [weak self] filter in
      self?.viewModel.applyFilter(filter: filter)
    }
    return UIHostingController(rootView: filtersView).view
  }
  
  private func applySnapshot(scrollToTop: Bool) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Character>()
    snapshot.appendSections([.main])
    snapshot.appendItems(viewModel.characters, toSection: .main)
        
    dataSource.apply(snapshot, animatingDifferences: !scrollToTop) { [weak self] in
        guard scrollToTop, let self = self else { return }
        if !self.viewModel.characters.isEmpty {
            self.tableView.scrollToRow(
                at: IndexPath(row: 0, section: 0),
                at: .top,
                animated: false
            )
        }
    }
  }
}
