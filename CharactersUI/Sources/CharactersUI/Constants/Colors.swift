import SwiftUI

extension Color {
  static let lightBlue = Color(red: 0.85, green: 0.93, blue: 1.0)
  static let lightRed = Color(red: 1.0, green: 0.90, blue: 0.90)
  static let lightGray = Color.gray.opacity(0.3)
  
}


extension Color {
  enum CaracterCard {
    enum Status {
      static let alive = Color.lightBlue
      static let dead = Color.lightRed
      static let unknown = Color.white
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
