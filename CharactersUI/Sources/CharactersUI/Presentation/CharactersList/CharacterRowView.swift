import SwiftUI

private enum Constants {
  static let imageDimension: CGFloat = 70
  static let cardCornerRadius: CGFloat = 12
  static let imageCornerRadius: CGFloat = 8
}

struct CharacterRowView: View {
  let character: Character
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      AsyncImage(url: character.imageUrl) { phase in
        switch phase {
        case .empty:
          ProgressView()
            .frame(width: Constants.imageDimension, height: Constants.imageDimension)
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
            .frame(width: Constants.imageDimension, height: Constants.imageDimension)
            .cornerRadius(Constants.imageCornerRadius)
        case .failure:
          Image(systemName: "person.fill")
            .resizable()
            .scaledToFill()
            .frame(width: Constants.imageDimension, height: Constants.imageDimension)
            .cornerRadius(Constants.imageCornerRadius)
            .foregroundColor(.gray)
        @unknown default:
            EmptyView()
        }
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(character.name)
          .font(.headline)
        Text(character.species)
          .font(.subheadline)
      }

      Spacer()
    }
    .padding()
    .background(backgroundColor)
    .cornerRadius(Constants.cardCornerRadius)
    .overlay(
      RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
        .stroke(borderColor, lineWidth: 1)
    )
    .padding([.horizontal, .top])
    
  }
  
  private var backgroundColor: Color {
    switch character.status {
    case .alive:
      Color.CaracterCard.Status.alive
    case .dead:
      Color.CaracterCard.Status.dead
    case .unknown:
      Color.CaracterCard.Status.unknown
    }
  }
  
  private var borderColor: Color {
    switch character.status {
    case .alive:
      Color.CaracterCard.Border.alive
    case .dead:
      Color.CaracterCard.Border.dead
    case .unknown:
      Color.CaracterCard.Border.unknown
    }
  }
}

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

struct CharacterRowView_Previews: PreviewProvider {
    static var previews: some View {
      CharacterRowView(
        character: .init(
          id: 1,
          name: "Rick Sanchez",
          imageUrl: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!,
          species: "Human",
          status: .alive,
          gender: "Male"
        )
      )
    }
}

