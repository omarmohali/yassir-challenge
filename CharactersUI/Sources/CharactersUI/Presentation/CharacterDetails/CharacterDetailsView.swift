import SwiftUI

struct CharacterDetailsView: View {
    let character: Character
    let backAction: () -> Void
    
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        ZStack(alignment: .topLeading) {
          AsyncImage(url: character.imageUrl) { image in
            image
              .resizable()
              .scaledToFill()
          } placeholder: {
            Color.gray.opacity(0.3)
          }
          .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
          .clipped()
          .cornerRadius(20)
          
          // Back button overlay
          Button(action: backAction) {
            Image(systemName: "arrow.left")
              .foregroundColor(.black)
              .frame(width: 40, height: 40)
              .background(Color.white.opacity(0.8))
              .clipShape(Circle())
          }
          .padding(.leading, 16)
          .padding(.top, 16)
          .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
          .shadow(radius: 3)
        }
        .frame(maxWidth: .infinity)
        
        // Name
        HStack {
          Text(character.name)
            .font(.title)
            .fontWeight(.bold)
          
          Spacer()
          
          Text(statusText(character.status))
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor(character.status))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        
        HStack {
          Text("\(character.species) · \(character.gender)")
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          Spacer()
        }
        .padding(.horizontal, 16)
        
        Spacer()
      }
    }
    .edgesIgnoringSafeArea(.top)
    .background(Color(UIColor.systemBackground))
  }
  
  private func statusText(_ status: Character.Status) -> String {
    switch status {
    case .alive:
      LocalizedString.CharacterDetails.Status.alive
    case .dead:
      LocalizedString.CharacterDetails.Status.dead
    case .unknown:
      LocalizedString.CharacterDetails.Status.unknown
    }
  }
  
  private func statusColor(_ status: Character.Status) -> Color {
    switch status {
    case .alive:
      Color.CaracterDetails.Status.Background.alive
    case .dead:
      Color.CaracterDetails.Status.Background.dead
    case .unknown:
      Color.CaracterDetails.Status.Background.unknown
    }
  }
}

struct CharacterDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    CharacterDetailsView(
      character: .init(
        id: 1,
        name: "Rick Sanchez",
        imageUrl: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!,
        species: "Human",
        status: .alive,
        gender: "Male"
      )
    ) {
      print("back")
    }
  }
}
