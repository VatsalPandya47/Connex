import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                WelcomePageView()
                    .tag(0)
                
                InterestsPageView()
                    .tag(1)
                
                ConnectionPreferencesView()
                    .tag(2)
            }
            .tabViewStyle(.page)
            
            Button(action: {
                viewModel.signInWithApple()
            }) {
                HStack {
                    Image(systemName: "applelogo")
                    Text("Continue with Apple")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

struct WelcomePageView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
            
            Text("Welcome to Connex")
                .font(.title)
                .bold()
            
            Text("Find meaningful connections based on shared interests and values")
                .multilineTextAlignment(.center)
                .padding()
        }
    }
} 