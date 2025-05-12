import SwiftUI
import CoreData

struct BookDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authViewModel: AuthViewModel

    let book: Book

    var body: some View {
        VStack {
            if let imageData = book.coverImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
            } else {
                Image(systemName: "book.closed.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
                    .padding()
            }

            Text(book.title ?? "Unknown Title")
                .font(.largeTitle)
                .padding(.bottom, 5)

            Text("by \(book.author ?? "Unknown Author")")
                .font(.title2)
                .foregroundColor(.gray)

            Spacer()

            VStack(spacing: 20) {
                Button {
                    // TODO: Implement Play functionality
                } label: {
                    Label("Play", systemImage: "play.circle.fill")
                        .font(.title)
                }

                // TODO: Add progress bar and other controls
                Text("Playback Controls Placeholder")
                    .foregroundColor(.secondary)
            }
            .padding()

            Spacer()
        }
        .navigationTitle(book.title ?? "Book Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let dummyBook = Book(context: context)
        dummyBook.title = "Sample Book"
        dummyBook.author = "Sample Author"
        dummyBook.dateAdded = Date()
        dummyBook.filePath = "dummy/path.epub"
        dummyBook.userID = "preview_user"

        return NavigationView {
            BookDetailView(book: dummyBook)
                .environment(\.managedObjectContext, context)
                .environmentObject(AuthViewModel())
        }
    }
}
