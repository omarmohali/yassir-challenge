import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      Text(message)
        .font(.headline)
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
      
      Button(action: onRetry) {
        Text(LocalizedString.Generic.retry)
          .fontWeight(.semibold)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
