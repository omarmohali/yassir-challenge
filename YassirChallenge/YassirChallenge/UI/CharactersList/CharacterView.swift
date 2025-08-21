import SwiftUI

struct CharacterView: View {
  let character: Character
  
  var body: some View {
    HStack(spacing: 12) {
      AsyncImage(url: character.imageUrl) { phase in
          switch phase {
          case .empty:
              ProgressView()
                  .frame(width: 50, height: 50)
          case .success(let image):
              image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 50, height: 50) // fixed size
                  .clipShape(Circle())          // round avatar
          case .failure:
              Image(systemName: "person.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 50, height: 50)
                  .clipShape(Circle())
                  .foregroundColor(.gray)
          @unknown default:
              EmptyView()
          }
      }

      Text(character.name)
          .font(.headline)

      Spacer()
  }
  .padding(.vertical, 8) // adds row spacing
    
  }
}

class CharacterTableViewCell: UITableViewCell {
    private var hostingController: UIHostingController<CharacterView>?

    func set(character: Character, parent: UIViewController) {
        let rootView = CharacterView(character: character)

        if let hostingController = hostingController {
            // Just update SwiftUI view
            hostingController.rootView = rootView
        } else {
            // Create new hosting controller
            let hc = UIHostingController(rootView: rootView)
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
}

