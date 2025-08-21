import UIKit

class CharactersListViewController: UITableViewController {
  private let viewModel: CharactersListViewModel
  
  init(viewModel: CharactersListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    viewModel.charactersDidChange = { [weak self] in
      self?.tableView.reloadData()
    }
    viewModel.didLoad()
    title = "UIKit Table with SwiftUI Cells"
    tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: "CharacterCell")
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.characters.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as! CharacterTableViewCell
    let character = viewModel.characters[indexPath.row]
    cell.set(character: character, parent: self)
    return cell
  }
}
