import SwiftUI

struct DataDownloadView: View {
    @StateObject private var viewModel = DataDownloadViewModel()
    
    var body: some View {
        List {
            Section {
                Text("Your data will be prepared and emailed to you within 48 hours. The download will include:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ForEach(DataType.allCases) { type in
                    DataTypeRow(type: type)
                }
            }
            
            Section {
                Button(action: viewModel.requestDownload) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Request Data Download")
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Download Data")
        .alert("Request Submitted", isPresented: $viewModel.showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You will receive an email when your data is ready to download.")
        }
    }
}

struct DataTypeRow: View {
    let type: DataType
    
    var body: some View {
        HStack {
            Image(systemName: type.icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(type.description)
        }
    }
}

enum DataType: String, CaseIterable, Identifiable {
    case profile
    case messages
    case moments
    case connections
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .profile: return "person.fill"
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .moments: return "rectangle.stack.fill"
        case .connections: return "person.2.fill"
        }
    }
    
    var description: String {
        switch self {
        case .profile: return "Profile Information"
        case .messages: return "Message History"
        case .moments: return "Moments and Interactions"
        case .connections: return "Connection History"
        }
    }
} 