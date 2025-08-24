import Foundation

func L10n(_ key: String) -> String {
  NSLocalizedString(key, tableName: "Localizable", bundle: Bundle.module, comment: "")
}

enum LocalizedString {
  enum CharactersList {
    enum Navigation {
      static let title = L10n("characters_list.navigation.title")
    }
  }
  enum CharacterDetails {
    enum Status {
      static let alive = L10n("character_details.status.alive")
      static let dead = L10n("character_details.status.dead")
      static let unknown = L10n("character_details.status.unknown")
    }
  }
  
  enum Generic {
    static let retry = L10n("generic_retry")
    static let somethingWentWrong = L10n("something_went_wrong")
  }
}
