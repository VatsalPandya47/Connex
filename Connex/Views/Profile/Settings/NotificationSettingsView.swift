import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotificationSettingsViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Push Notifications")) {
                Toggle("New Matches", isOn: $viewModel.newMatches)
                Toggle("Messages", isOn: $viewModel.messages)
                Toggle("Moment Likes", isOn: $viewModel.momentLikes)
                Toggle("Moment Comments", isOn: $viewModel.momentComments)
            }
            
            Section(header: Text("Email Notifications")) {
                Toggle("Weekly Activity Digest", isOn: $viewModel.weeklyDigest)
                Toggle("Special Offers", isOn: $viewModel.specialOffers)
            }
        }
        .navigationTitle("Notifications")
    }
} 