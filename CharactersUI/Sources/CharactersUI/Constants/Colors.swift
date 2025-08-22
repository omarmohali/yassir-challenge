import SwiftUI

extension Color {
  static var lightBlue: Color {
    Color(UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark
      ? UIColor(red: 0.15, green: 0.25, blue: 0.35, alpha: 1)
      : UIColor(red: 0.85, green: 0.93, blue: 1.0, alpha: 1)
    })
  }

  static var lightRed: Color {
    Color(UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark
      ? UIColor(red: 0.25, green: 0.15, blue: 0.15, alpha: 1)
      : UIColor(red: 1.0, green: 0.90, blue: 0.90, alpha: 1)
    })
  }
  
  static let lightGray = Color.gray.opacity(0.3)
  
}


extension Color {
  enum CaracterCard {
    enum Status {
      static let alive = Color.lightBlue
      static let dead = Color.lightRed
      static let unknown = Color(.systemBackground)
    }
    
    enum Border {
      static let alive = Color.lightBlue
      static let dead = Color.lightRed
      static let unknown = Color.lightGray
    }
  }
  
  enum CaracterDetails {
    enum Status {
      enum Background {
        static let alive = Color.lightBlue
        static let dead = Color.lightRed
        static let unknown = Color.lightGray
      }
    }
  }
}
