import SwiftUI

class CharacterTableViewCell: UITableViewCell {
    private var hostingController: UIHostingController<CharacterRowView>?

    func set(character: Character, parent: UIViewController) {
      hostingController?.willMove(toParent: nil)
      hostingController?.view.removeFromSuperview()
      hostingController?.removeFromParent()

      let hc = UIHostingController(rootView: CharacterRowView(character: character))
      hc.view.backgroundColor = .clear

      parent.addChild(hc)
      contentView.addSubview(hc.view)

      hc.view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        hc.view.topAnchor.constraint(equalTo: contentView.topAnchor),
        hc.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        hc.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        hc.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
      ])

      hc.didMove(toParent: parent)
      hostingController = hc
    }
}
