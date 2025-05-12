import SwiftUI

struct BookRow: View {
    let book: Book
    var downloadAction: () -> Void
    var isDownloading: Bool
    var isDownloaded: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            AsyncImage(url: URL(string: book.formats.imageJpeg ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    Image(systemName: "book.closed")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 70, height: 100)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(5)

            VStack(alignment: .leading, spacing: 5) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(book.authors.map { $0.name }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)

                if let downloadCount = book.downloadCount {
                    Text("Downloads: \(downloadCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()

                if isDownloaded {
                    Text("Downloaded")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.vertical, 5)
                } else if isDownloading {
                    ProgressView()
                        .padding(.vertical, 5)
                } else {
                    Button(action: downloadAction) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Download")
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer() 
        }
        .padding(.vertical, 8)
    }
}
