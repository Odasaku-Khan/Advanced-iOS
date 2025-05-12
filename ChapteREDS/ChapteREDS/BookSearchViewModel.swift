import SwiftUI
import Combine
import CoreData

@MainActor
class BookSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var books: [Book] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var currentPage: Int = 1
    @Published var totalResults: Int = 0
    @Published var canLoadMore: Bool = false

    @Published var downloadedBookIDs: Set<Int> = []
    @Published var downloadingBookIDs: Set<Int> = []

    private let gutendexService = GutendexService()
    private let fileDownloader = FileDownloader()
    private let bookStorageService: BookStorageService

    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.bookStorageService = BookStorageService(context: context)
        
        $searchText
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newSearchText in
                guard let self = self else { return } // Corrected weak self handling
                if !newSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || self.books.isEmpty == true {
                    self.performSearch(query: newSearchText, newSearch: true)
                } else if newSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.books = []
                    self.totalResults = 0
                    self.currentPage = 1
                    self.canLoadMore = false
                    self.errorMessage = nil
                }
            }
            .store(in: &cancellables)
        
        loadInitialDownloadedIDs()
    }
    
    private func loadInitialDownloadedIDs() {
        self.downloadedBookIDs = self.bookStorageService.fetchDownloadedBookIDs()
        print("BookSearchViewModel: Loaded initial downloadedBookIDs: \(self.downloadedBookIDs.count) items.")
    }

    func performSearch(query: String, newSearch: Bool) {
        if newSearch {
            currentPage = 1
            books = []
            totalResults = 0
            canLoadMore = false
        }
        
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        let effectiveQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            do {
                let results = try await gutendexService.searchBooks(query: effectiveQuery, page: currentPage)
                
                if newSearch {
                    self.books = results.results
                } else {
                    self.books.append(contentsOf: results.results)
                }
                
                self.totalResults = results.count
                self.currentPage += 1
                self.canLoadMore = results.next != nil && !self.books.isEmpty
                
            } catch let gutendexError as GutendexError {
                switch gutendexError {
                case .invalidURL:
                    self.errorMessage = "Invalid URL for search."
                case .networkError(let underlyingError):
                    self.errorMessage = "Network error: \(underlyingError.localizedDescription)"
                case .decodingError(let underlyingError):
                    self.errorMessage = "Failed to decode book data: \(underlyingError.localizedDescription)"
                case .serverError(let statusCode):
                    self.errorMessage = "Server error: \(statusCode)."
                case .noData:
                    self.errorMessage = "No data received from server."
                }
                print("BookSearchViewModel Error: \(self.errorMessage ?? "Unknown GutendexError")")
            } catch {
                self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                print("BookSearchViewModel Error: \(self.errorMessage ?? "Unknown error")")
            }
            self.isLoading = false
        }
    }
    
    func loadMoreBooksIfNeeded(currentItem item: Book?) {
        guard let item = item else {
            if !books.isEmpty && canLoadMore && !isLoading {
                 performSearch(query: searchText, newSearch: false)
            }
            return
        }

        let thresholdIndex = books.index(books.endIndex, offsetBy: -5)
        if books.firstIndex(where: { $0.id == item.id }) == thresholdIndex && canLoadMore && !isLoading {
            performSearch(query: searchText, newSearch: false)
        }
    }

    func downloadBook(_ book: Book) {
        guard !downloadedBookIDs.contains(book.id) && !downloadingBookIDs.contains(book.id) else {
            print("BookSearchViewModel: Book ID \(book.id) is already downloaded or downloading.")
            return
        }

        var urlToDownloadString: String? = nil
        var determinedMediaType: String? = nil

        if let epubUrl = book.formats.applicationEpubZip {
            urlToDownloadString = epubUrl
            determinedMediaType = "application/epub+zip"
        } else if let textUrl = book.formats.textPlainCharsetUtf8 {
            urlToDownloadString = textUrl
            determinedMediaType = "text/plain; charset=utf-8"
        } else if let textUrlAscii = book.formats.textPlainCharsetUsAscii {
            urlToDownloadString = textUrlAscii
            determinedMediaType = "text/plain; charset=us-ascii"
        } else if let textPlain = book.formats.textPlain {
            urlToDownloadString = textPlain
            determinedMediaType = "text/plain"
        }

        guard let urlString = urlToDownloadString, let downloadURL = URL(string: urlString) else {
            print("BookSearchViewModel: No suitable download URL found for book ID \(book.id).")
            self.errorMessage = "No download link available for this book."
            return
        }

        print("BookSearchViewModel: Attempting to download book '\(book.title)' from URL: \(downloadURL)")
        downloadingBookIDs.insert(book.id)
        errorMessage = nil

        Task { // This Task block now contains the actual download/save logic
            do {
                let localFileURL = try await fileDownloader.downloadFile(
                    from: downloadURL,
                    bookId: book.id,
                    originalUrlString: urlString
                )
                
                try bookStorageService.saveBook(
                    gutendexId: Int64(book.id),
                    title: book.title,
                    authors: book.authors.map { $0.name },
                    localFilePath: localFileURL.path,
                    coverImageURL: book.formats.imageJpeg,
                    sourceURL: urlString,
                    mediaType: determinedMediaType ?? book.mediaType
                )
                
                print("BookSearchViewModel: Successfully downloaded and saved book ID \(book.id). Path: \(localFileURL.path)")
                self.downloadingBookIDs.remove(book.id)
                self.downloadedBookIDs.insert(book.id)
            } catch {
                print("BookSearchViewModel: Failed to download or save book ID \(book.id). Error: \(error.localizedDescription)")
                self.downloadingBookIDs.remove(book.id)
                if let downloadError = error as? DownloadError {
                     self.errorMessage = "Download failed for '\(book.title)': \(downloadError)"
                } else if let coreDataError = error as? NSError, coreDataError.domain == NSCocoaErrorDomain {
                     self.errorMessage = "Failed to save '\(book.title)' to library."
                }
                else {
                    self.errorMessage = "Download failed for '\(book.title)'."
                }
            }
        }
    }
}
