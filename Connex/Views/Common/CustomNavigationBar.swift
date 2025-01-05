import SwiftUI

struct CustomNavigationBar<Leading: View, Trailing: View>: View {
    let title: String
    let leading: Leading
    let trailing: Trailing
    
    init(
        title: String,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack {
            leading
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            trailing
                .frame(width: 60, alignment: .trailing)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Divider()
                .padding(.top, 44)
            , alignment: .bottom
        )
    }
}

extension View {
    func customNavigationBar<Leading: View, Trailing: View>(
        title: String,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) -> some View {
        self.safeAreaInset(edge: .top) {
            CustomNavigationBar(
                title: title,
                leading: leading,
                trailing: trailing
            )
        }
    }
}

// Example usage:
struct ExampleView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Color.clear
            .customNavigationBar(
                title: "Example",
                leading: {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                    }
                },
                trailing: {
                    Button {
                        // Action
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            )
    }
} 