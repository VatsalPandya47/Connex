import SwiftUI

struct UserFeedbackView: View {
    @State private var feedbackText = ""
    @State private var isSubmitting = false
    @State private var submissionResult: Result<Void, Error>?
    
    var body: some View {
        VStack {
            Text("We Value Your Feedback")
                .font(.title2)
            
            TextEditor(text: $feedbackText)
                .frame(height: 150)
                .border(Color.gray.opacity(0.2))
                .padding()
            
            Button(action: submitFeedback) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text("Submit Feedback")
                }
            }
            .disabled(feedbackText.isEmpty || isSubmitting)
            
            // Feedback submission result
            if let result = submissionResult {
                switch result {
                case .success:
                    Text("Thank you for your feedback!")
                        .foregroundColor(.green)
                case .failure(let error):
                    Text("Submission failed: \(error.localizedDescription)")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        // Submit feedback to Firestore
        let feedbackData: [String: Any] = [
            "text": feedbackText,
            "timestamp": FieldValue.serverTimestamp(),
            "userID": FirebaseManager.shared.getCurrentUserID() ?? "anonymous"
        ]
        
        FirebaseManager.shared.firestore
            .collection("user_feedback")
            .addDocument(data: feedbackData) { error in
                isSubmitting = false
                
                if let error = error {
                    submissionResult = .failure(error)
                    error.report(context: "User Feedback Submission")
                } else {
                    submissionResult = .success(())
                    feedbackText = ""
                }
            }
    }
} 