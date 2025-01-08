import SwiftUI

struct ErrorHandlingView: View {
    let error: Error
    let context: String?
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            
            Text("An Error Occurred")
                .font(.headline)
            
            Text(error.localizedDescription)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let context = context {
                Text("Context: \(context)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Button(action: { showDetails.toggle() }) {
                Text(showDetails ? "Hide Details" : "Show Details")
            }
            
            if showDetails {
                ScrollView {
                    Text(debugDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            HStack {
                Button("Report") {
                    reportError()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Dismiss") {
                    // Dismiss error handling
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .onAppear {
            AnalyticsService.shared.logError(error, context: context)
        }
    }
    
    private var debugDescription: String {
        return """
        Error: \(error.localizedDescription)
        Type: \(type(of: error))
        Context: \(context ?? "N/A")
        Debug Info: \(String(describing: error))
        """
    }
    
    private func reportError() {
        // Implement error reporting mechanism
        // Could open email, send to support backend, etc.
        Logger.log("Error Reported: \(error.localizedDescription)", level: .critical)
    }
}

// Extension to make error reporting easier
extension Error {
    func report(context: String? = nil) {
        AnalyticsService.shared.logError(self, context: context)
    }
} 