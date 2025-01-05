import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section("Account") {
                    NavigationLink {
                        EditProfileView(user: authService.currentUser!)
                    } label: {
                        Text("Edit Profile")
                    }
                    
                    NavigationLink {
                        ChangePasswordView()
                    } label: {
                        Text("Change Password")
                    }
                }
                
                // Privacy Section
                Section("Privacy") {
                    NavigationLink {
                        PrivacySettingsView(settings: $viewModel.settings.privacySettings)
                    } label: {
                        Text("Privacy Settings")
                    }
                    
                    NavigationLink {
                        BlockedUsersView()
                    } label: {
                        Text("Blocked Users")
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    NavigationLink {
                        NotificationSettingsView(preferences: $viewModel.settings.notificationPreferences)
                    } label: {
                        Text("Notification Preferences")
                    }
                }
                
                // Discovery Section
                Section("Discovery") {
                    NavigationLink {
                        DiscoverySettingsView(settings: $viewModel.settings.discoverySettings)
                    } label: {
                        Text("Discovery Settings")
                    }
                }
                
                // Support Section
                Section("Support") {
                    NavigationLink {
                        HelpCenterView()
                    } label: {
                        Text("Help Center")
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
                
                // Account Actions Section
                Section {
                    Button("Sign Out") {
                        showSignOutAlert = true
                    }
                    .foregroundColor(.red)
                    
                    Button("Delete Account") {
                        showDeleteAccountAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Implement account deletion
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct PrivacySettingsView: View {
    @Binding var settings: UserSettings.PrivacySettings
    
    var body: some View {
        Form {
            Section("Profile Visibility") {
                Picker("Who can see your profile", selection: $settings.profileVisibility) {
                    Text("Everyone").tag(UserSettings.PrivacySettings.ProfileVisibility.everyone)
                    Text("Connections").tag(UserSettings.PrivacySettings.ProfileVisibility.connections)
                    Text("Nobody").tag(UserSettings.PrivacySettings.ProfileVisibility.nobody)
                }
            }
            
            Section("Online Status") {
                Picker("Who can see when you're online", selection: $settings.onlineStatus) {
                    Text("Everyone").tag(UserSettings.PrivacySettings.OnlineStatusVisibility.everyone)
                    Text("Connections").tag(UserSettings.PrivacySettings.OnlineStatusVisibility.connections)
                    Text("Nobody").tag(UserSettings.PrivacySettings.OnlineStatusVisibility.nobody)
                }
            }
            
            Section("Last Seen") {
                Picker("Who can see your last seen", selection: $settings.lastSeen) {
                    Text("Everyone").tag(UserSettings.PrivacySettings.LastSeenVisibility.everyone)
                    Text("Connections").tag(UserSettings.PrivacySettings.LastSeenVisibility.connections)
                    Text("Nobody").tag(UserSettings.PrivacySettings.LastSeenVisibility.nobody)
                }
            }
        }
        .navigationTitle("Privacy Settings")
    }
}

struct NotificationSettingsView: View {
    @Binding var preferences: UserSettings.NotificationPreferences
    
    var body: some View {
        Form {
            Section {
                Toggle("Push Notifications", isOn: $preferences.pushEnabled)
                    .tint(.accentColor)
            }
            
            Section("Notify Me About") {
                Toggle("Connection Requests", isOn: $preferences.connectionRequests)
                    .tint(.accentColor)
                Toggle("Messages", isOn: $preferences.messages)
                    .tint(.accentColor)
                Toggle("Connection Updates", isOn: $preferences.connectionUpdates)
                    .tint(.accentColor)
            }
            
            Section("Email Notifications") {
                Toggle("Email Notifications", isOn: $preferences.emailNotifications)
                    .tint(.accentColor)
            }
        }
        .navigationTitle("Notifications")
    }
}

struct DiscoverySettingsView: View {
    @Binding var settings: UserSettings.DiscoverySettings
    
    var body: some View {
        Form {
            Section {
                Toggle("Show Me in Discovery", isOn: $settings.discoverable)
                    .tint(.accentColor)
            }
            
            Section("Distance") {
                Stepper("Maximum Distance: \(settings.maxDistance) km", value: $settings.maxDistance, in: 1...100)
            }
            
            Section("Age Range") {
                RangeSlider(range: $settings.ageRange, bounds: 18...100)
                    .padding(.vertical)
                
                Text("Age Range: \(settings.ageRange.lowerBound) - \(settings.ageRange.upperBound)")
                    .foregroundColor(.secondary)
            }
            
            Section("Interests") {
                ForEach(settings.interests, id: \.self) { interest in
                    Text(interest)
                }
                .onDelete { indexSet in
                    settings.interests.remove(atOffsets: indexSet)
                }
                
                NavigationLink {
                    InterestsSelectionView(selectedInterests: $settings.interests)
                } label: {
                    Text("Edit Interests")
                }
            }
        }
        .navigationTitle("Discovery")
    }
}

struct BlockedUsersView: View {
    @StateObject private var viewModel = BlockedUsersViewModel()
    
    var body: some View {
        List {
            if viewModel.blockedUsers.isEmpty {
                Text("No blocked users")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.blockedUsers) { user in
                    HStack {
                        Text("\(user.firstName) \(user.lastName)")
                        Spacer()
                        Button("Unblock") {
                            viewModel.unblockUser(user)
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.loadBlockedUsers()
        }
    }
}

struct FAQView: View {
    let faqs = [
        FAQ(question: "How do I change my profile photo?", 
            answer: "Go to your profile, tap 'Edit Profile', then tap on your profile photo to change it."),
        FAQ(question: "How do connections work?", 
            answer: "When you send a connection request, the other person will be notified. If they accept, you'll be connected and can start chatting."),
        FAQ(question: "Can I change my email address?", 
            answer: "Contact support to change your email address. This helps us maintain account security."),
        // Add more FAQs...
    ]
    
    var body: some View {
        List(faqs) { faq in
            DisclosureGroup(faq.question) {
                Text(faq.answer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
} 