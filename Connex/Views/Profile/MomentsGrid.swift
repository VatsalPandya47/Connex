import SwiftUI

struct MomentsGrid: View {
    let moments: [Moment]
    let onLike: (Moment) -> Void
    @State private var selectedMoment: Moment?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Moments")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(moments) { moment in
                    MomentThumbnail(moment: moment) {
                        selectedMoment = moment
                    }
                }
            }
        }
        .sheet(item: $selectedMoment) { moment in
            MomentDetailView(moment: moment, onLike: onLike)
        }
    }
}

struct MomentThumbnail: View {
    let moment: Moment
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if let imageURL = moment.mediaURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
                .aspectRatio(1, contentMode: .fill)
                .clipped()
            } else {
                Text(moment.content)
                    .font(.caption)
                    .lineLimit(3)
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .background(Color(.systemGray6))
            }
        }
    }
}

struct MomentDetailView: View {
    let moment: Moment
    let onLike: (Moment) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let imageURL = moment.mediaURL {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Color(.systemGray5)
                        }
                    }
                    
                    Text(moment.content)
                        .font(.body)
                        .padding(.horizontal)
                    
                    HStack {
                        Button {
                            onLike(moment)
                        } label: {
                            Label("\(moment.likeCount)", systemImage: moment.isLiked ? "heart.fill" : "heart")
                        }
                        
                        Spacer()
                        
                        Text(moment.createdAt.timeAgoDisplay())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 