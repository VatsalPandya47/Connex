import SwiftUI

struct MomentsView: View {
    @StateObject private var viewModel = MomentsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.moments) { moment in
                        MomentCard(moment: moment)
                    }
                }
                .padding()
            }
            .navigationTitle("Moments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.createNewMoment) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
}

struct MomentCard: View {
    let moment: Moment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let url = moment.mediaURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipped()
            }
            
            Text(moment.content)
                .padding(.horizontal)
            
            HStack {
                Button(action: {}) {
                    Label("\(moment.likes)", systemImage: "heart")
                }
                
                Spacer()
                
                Button(action: {}) {
                    Label("\(moment.comments.count)", systemImage: "bubble.right")
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 