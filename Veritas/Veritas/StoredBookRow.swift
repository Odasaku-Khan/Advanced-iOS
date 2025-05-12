import SwiftUI

struct StoredBookRow: View {
    @ObservedObject var storedBook: StoredBook

    var body: some View {
        HStack(spacing: 16) { 
            AsyncImage(url: URL(string: storedBook.coverImageURL ?? "")) { phase in 
                switch phase {
                case .empty: 
                    ZStack { 
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1)) 
                        ProgressView()
                    }
                    .frame(width: 80, height: 120) 
                        
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill) 
                        .frame(width: 80, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8)) 
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 1, y: 2) 

                case .failure: 
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                        Image(systemName: "book.closed.fill") 
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.gray.opacity(0.6))
                    }
                    .frame(width: 80, height: 120)

                @unknown default:
                    EmptyView() 
                }
            }
            .frame(width: 80, height: 120) 

            VStack(alignment: .leading, spacing: 6) { 
                Text(storedBook.title ?? "Untitled Book")
                    .font(.headline)
                    .lineLimit(2) 
                    .truncationMode(.tail)

                Text(storedBook.authors ?? "Unknown Author(s)") 
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                if let date = storedBook.downloadDate {
                    Text("Added: \(date, style: .date)")
                        .font(.caption)
                        .foregroundColor(.tertiary)
                }
                Spacer() 
            }
            Spacer() 
        }
        .padding(.vertical, 8) 
    }
}

struct StoredBookRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleBook = StoredBook(context: context)
        sampleBook.gutendexId = 12345 
        sampleBook.title = "A Very Long Book Title That Might Wrap Around to Multiple Lines"
        sampleBook.authors = "An Author with a Readable Name, Another Author" 
        sampleBook.coverImageURL = "https://placehold.co/120x180/007AFF/FFFFFF?text=RowPreview" 
        sampleBook.downloadDate = Date()

        return Group {
            StoredBookRow(storedBook: sampleBook)
                .padding(.horizontal) 
                .previewLayout(.sizeThatFits) 

            StoredBookRow(storedBook: { 
                let book = StoredBook(context: context)
                book.gutendexId = 67890 
                book.title = "Book Without Cover"
                book.authors = "Anonymous" 
                book.downloadDate = Date().addingTimeInterval(-86400 * 5) 
                return book
            }())
            .padding(.horizontal)
            .previewLayout(.sizeThatFits)
        }
    }
}
