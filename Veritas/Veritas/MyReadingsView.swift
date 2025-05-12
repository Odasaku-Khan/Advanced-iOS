import SwiftUI
import CoreData 

struct MyReadingsView: View {
    @StateObject private var viewModel: MyReadingsViewModel
    
    @MainActor
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _viewModel = StateObject(wrappedValue: MyReadingsViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            Group { 
                if viewModel.isLoading && viewModel.storedBooks.isEmpty {
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
                            viewModel.fetchStoredBooks() 
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .padding()
                } else if viewModel.storedBooks.isEmpty { 
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
                        Button("Add Sample Book (Test)") { 
                             viewModel.addSampleBookForTesting() 
                        }
                        .buttonStyle(.bordered)
                        .padding(.top)
                        Spacer()
                        Spacer() 
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.storedBooks) { book in 
                            NavigationLink(destination: BookDetailViewPlaceholder(book: book)) {
                                StoredBookRow(storedBook: book)
                            }
                        }
                        .onDelete(perform: viewModel.deleteBook) 
                    }
                    .listStyle(.plain) 
                    .refreshable { 
                        viewModel.fetchStoredBooks() 
                    }
                }
            }
            .navigationTitle("My Library")
            .toolbar { 
                if !viewModel.storedBooks.isEmpty {
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
