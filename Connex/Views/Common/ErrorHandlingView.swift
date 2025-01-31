import SwiftUI

struct ErrorHandlingView: View {
    let error: Error
    let context: String?
    
    var body: some View {
        VStack {
            Text("Error")
                .font(.title)
            Text(error.localizedDescription)
                .foregroundColor(.red)
            if let context = context {
                Text("Context: \(context)")
                    .font(.caption)
            }
        }
    }
} 