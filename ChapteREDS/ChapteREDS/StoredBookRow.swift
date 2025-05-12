import SwiftUI

struct StoredBookRow: View {
    let storedBook: StoredBook

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            AsyncImage(url: URL(string: storedBook.coverImageURL ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .frame(width: 70, height: 100)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(5)

            VStack(alignment: .leading, spacing: 5) {
                Text(storedBook.title ?? "Unknown Title")
                    .font(.headline)
                    .lineLimit(2)
                
                Text(storedBook.authors ?? "Unknown Author(s)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)

                if let downloadDate = storedBook.downloadDate {
                    Text("Downloaded: \(downloadDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
