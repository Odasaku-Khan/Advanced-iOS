import SwiftUI
import CoreData // Import CoreData to recognize NSManagedObjectContext

struct BookDetailViewPlaceholder: View {
    @ObservedObject var book: StoredBook

    var body: some View {
        VStack {
            Text("Details for: \(book.title ?? "Book")")
                .font(.largeTitle)
            
            if let coverURL = book.coverImageURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
            }
            Text("Author(s): \(book.authors ?? "N/A")")
            Spacer()
        }
        .navigationTitle(book.title ?? "Book Details")
    }
}


struct MyReadingsView: View {
    @StateObject private var viewModel: MyReadingsViewModel
    
    @MainActor
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _viewModel = StateObject(wrappedValue: MyReadingsViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            Group {
                // Use viewModel.storeBook as per the user's provided MyReadingsViewModel
                if viewModel.isLoading && viewModel.storeBook.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading your library...")
                            .scaleEffect(1.2)
                        Spacer()
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.headline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry Fetch") {
                            // fetchStoredBooks is now synchronous in the user's ViewModel
                            viewModel.fetchStoredBooks()
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .padding()
                } else if viewModel.storeBook.isEmpty { // Use viewModel.storeBook
                    VStack(spacing: 15) {
                        Spacer()
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Your Library is Empty")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("Books you download will appear here.\nGo to the Search tab to find new books!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        // Button("Add Sample Book (Test)") {
                        //      Task { await viewModel.addSampleBookForTesting() } // This method is not in the user's new ViewModel
                        // }
                        // .buttonStyle(.bordered)
                        // .padding(.top)
                        Spacer()
                        Spacer()
                    }
                    .padding()
                } else {
                    List {
                        // Use viewModel.storeBook
                        ForEach(viewModel.storeBook) { book in
                            NavigationLink(destination: BookDetailViewPlaceholder(book: book)) {
                                StoredBookRow(storedBook: book)
                            }
                        }
                        .onDelete(perform: viewModel.deleteBook)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        // fetchStoredBooks is now synchronous in the user's ViewModel
                        viewModel.fetchStoredBooks()
                    }
                }
            }
            .navigationTitle("My Library")
            .toolbar {
                // Use viewModel.storeBook
                if !viewModel.storeBook.isEmpty {
                    EditButton()
                }
            }
            .onAppear {
                print("MyReadingsView: Appeared.")
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct MyReadingsView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        return MyReadingsView(context: previewContext)
    }
}
