import SwiftUI

struct BookSearchView: View {
    @StateObject private var viewModel = BookSearchViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Search for books...", text: $viewModel.searchText)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)

                if viewModel.isLoading && viewModel.books.isEmpty {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack {
                        Text("Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            viewModel.performSearch(query: viewModel.searchText, newSearch: true)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                } else if viewModel.books.isEmpty && !viewModel.searchText.isEmpty && !viewModel.isLoading {
                    Spacer()
                    Text("No books found for '\(viewModel.searchText)'.")
                        .foregroundColor(.secondary)
                    Spacer()
                } else if viewModel.books.isEmpty && viewModel.searchText.isEmpty && !viewModel.isLoading {
                     Spacer()
                     Text("Enter a search term to find books, or type anything to see popular books.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                     Spacer()
                } else {
                    List {
                        ForEach(viewModel.books) { book in
                            BookRow(
                                book: book,
                                downloadAction: {
                                    viewModel.downloadBook(book)
                                },
                                isDownloading: viewModel.downloadingBookIDs.contains(book.id),
                                isDownloaded: viewModel.downloadedBookIDs.contains(book.id)
                            )
                            .onAppear {
                                viewModel.loadMoreBooksIfNeeded(currentItem: book)
                            }
                        }
                        if viewModel.isLoading && !viewModel.books.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        }
                        if !viewModel.books.isEmpty && viewModel.canLoadMore && !viewModel.isLoading {
                             Color.clear
                                .frame(height: 1)
                                .onAppear {
                                     viewModel.loadMoreBooksIfNeeded(currentItem: nil)
                                 }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search Books")
            .onAppear {
                if viewModel.searchText.isEmpty && viewModel.books.isEmpty {
                     viewModel.performSearch(query: "", newSearch: true)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct BookSearchView_Previews: PreviewProvider {
    static var previews: some View {
        BookSearchView()
    }
}
