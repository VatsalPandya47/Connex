//
//  ContentView.swift
//  Connex
//
//  Created by Vatsal Pandya on 1/5/25.
//

import SwiftUI
import Combine
import Firebase

// Explicitly import local modules
import Foundation
import class ViewModels.AuthViewModel
import struct Views.Authentication.AuthenticationView
import struct Views.Common.LoadingView
import struct Views.MainTabView
import struct Views.Common.ErrorHandlingView
import class App.AppState

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            switch authViewModel.authState {
            case .unauthenticated:
                AuthenticationView()
            case .authenticating:
                LoadingView(message: "Authenticating...")
            case .authenticated:
                MainTabView()
            case .error:
                ErrorHandlingView(
                    error: authViewModel.authError ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown authentication error"]),
                    context: "Authentication"
                )
            }
        }
        .alert(isPresented: $appState.showingError) {
            Alert(
                title: Text("Error"),
                message: Text(appState.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .environmentObject(authViewModel)
        .environmentObject(appState)
    }
}

// Preview for development
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
