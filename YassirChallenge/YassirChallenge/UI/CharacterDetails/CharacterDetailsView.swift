import SwiftUI

struct CharacterDetailsView: View {
  let character: Character
  
  var body: some View {
    Text(character.name)
  }
}
