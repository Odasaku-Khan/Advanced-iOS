import SwiftUI

struct BookDetailViewPlaceholder: View {
    @ObservedObject var book: StoredBook
    var body: some View {
        ScrollView { 
            VStack(alignment: .leading, spacing: 15) {
                Text(book.title ?? "Book Details")
                    .font(.largeTitle)
                    .padding(.bottom)

                if let coverURLString = book.coverImageURL, let url = URL(string: coverURLString) { 
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 250)
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300) 
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 5)
                        case .failure:
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .frame(height: 250)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.bottom)
                }

                Text("Author(s):")
                    .font(.headline)
                Text(book.authors ?? "N/A") 
                    .font(.body)

                Text("File Path:")
                    .font(.headline)
                Text(book.localFilePath ?? "N/A") 
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Text("Source URL:")
                    .font(.headline)
                Text(book.sourceURL ?? "N/A") 
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text("Media Type:")
                    .font(.headline)
                Text(book.mediaType ?? "N/A") 
                    .font(.body)

                if let downloadDate = book.downloadDate {
                    Text("Date Added:")
                        .font(.headline)
                    Text("\(downloadDate, style: .date) at \(downloadDate, style: .time)")
                        .font(.body)
                }
                
                Text("Gutendex ID: \(book.gutendexId)") 
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Start Reading (Placeholder)") {
                    print("Attempting to read: \(book.title ?? "Unknown") from Veritas project")
                }
                .padding()
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(book.title ?? "Details") 
        .navigationBarTitleDisplayMode(.inline) 
    }
}

struct BookDetailViewPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleBook = StoredBook(context: context)
        sampleBook.gutendexId = 1001
        sampleBook.title = "A Gripping Novel of Adventure"
        sampleBook.authors = "Jane Doe, John Smith" 
        sampleBook.coverImageURL = "https://placehold.co/200x300/FFA500/FFFFFF?text=DetailPreview" 
        sampleBook.localFilePath = "/path/to/gripping_novel.epub" 
        sampleBook.downloadDate = Date()
        sampleBook.sourceURL = "http://example.com/gripping_novel"
        sampleBook.mediaType = "application/epub+zip"
        
        return NavigationView { 
            BookDetailViewPlaceholder(book: sampleBook)
        }
    }
}
