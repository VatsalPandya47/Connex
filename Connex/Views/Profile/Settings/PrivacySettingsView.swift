import SwiftUI

struct PrivacySettingsView: View {
    @StateObject private var viewModel = PrivacySettingsViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Profile Visibility")) {
                Toggle("Show Profile in Discovery", isOn: $viewModel.showInDiscovery)
                Toggle("Show Online Status", isOn: $viewModel.showOnlineStatus)
                Toggle("Show Last Active", isOn: $viewModel.showLastActive)
            }
            
            Section(header: Text("Moments Privacy")) {
                Picker("Default Moments Privacy", selection: $viewModel.defaultMomentsPrivacy) {
                    Text("Public").tag(MomentsPrivacy.public)
                    Text("Connections Only").tag(MomentsPrivacy.connectionsOnly)
                    Text("Private").tag(MomentsPrivacy.private)
                }
            }
            
            Section(header: Text("Blocking")) {
                NavigationLink("Blocked Users") {
                    BlockedUsersView()
                }
            }
        }
        .navigationTitle("Privacy")
    }
}

enum MomentsPrivacy: String {
    case `public`
    case connectionsOnly
    case `private`
} 