import SwiftUI

struct HelpCenterView: View {
    var body: some View {
        List {
            Section(header: Text("Common Issues")) {
                NavigationLink(destination: FAQView()) {
                    Text("Frequently Asked Questions")
                }
                NavigationLink(destination: ContactSupportView()) {
                    Text("Contact Support")
                }
            }
            
            Section(header: Text("App Information")) {
                Text("Version: \(Bundle.main.appVersion)")
                Text("Privacy Policy")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if let url = URL(string: "https://example.com/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }
                Text("Terms of Service")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if let url = URL(string: "https://example.com/terms") {
                            UIApplication.shared.open(url)
                        }
                    }
            }
        }
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContactSupportView: View {
    @State private var email = ""
    @State private var message = ""
    @State private var showAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Contact Support")) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                TextEditor(text: $message)
                    .frame(height: 150)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
            }
            
            Button("Send") {
                // Implement sending support message
                showAlert = true
            }
            .alert("Message Sent", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your message has been sent to support.")
            }
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
    }
} 