import SwiftUI
import Combine
import CoreData

@MainActor
class MyReadingsViewModel: ObservableObject {
    @Published var storedBooks: [StoredBook] = [] 
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let bookStorageService: BookStorageService

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.bookStorageService = BookStorageService(context: context)
        print("MyReadingsViewModel: Initialized for Veritas.")
        self.fetchStoredBooks() 
    }

    func fetchStoredBooks() {
        print("MyReadingsViewModel: Starting fetchStoredBooks.")
        isLoading = true
        errorMessage = nil
        
        let fetchedBooks = bookStorageService.fetchStoredBooks()
        self.storedBooks = fetchedBooks.sorted { 
            ($0.downloadDate ?? Date.distantPast) > ($1.downloadDate ?? Date.distantPast)
        }
        
        isLoading = false
        if self.storedBooks.isEmpty {
            print("MyReadingsViewModel: Library is empty after fetch.")
        } else {
            print("MyReadingsViewModel: Fetched \(self.storedBooks.count) books.")
        }
    }

    func deleteBook(at indexSet: IndexSet) {
        isLoading = true 
        errorMessage = nil

        let booksToDelete = indexSet.map { self.storedBooks[$0] } 
        
        var anErrorOccurred = false
        for book in booksToDelete {
            do {
                try self.bookStorageService.deleteBook(storedBook: book) 
            } catch {
                let title = book.title ?? "Untitled"
                print("MyReadingsViewModel: Error deleting book '\(title)': \(error.localizedDescription)")
                anErrorOccurred = true
            }
        }
        
        self.fetchStoredBooks() 
        
        if anErrorOccurred && self.errorMessage == nil { 
            self.errorMessage = "One or more books could not be deleted. Please try again."
        }
    }
    
    func addSampleBookForTesting() { 
        print("MyReadingsViewModel: Adding sample book for testing.")
        isLoading = true
        do {
            let randomNumber = Int64.random(in: 1000...9999)
            try bookStorageService.saveBook( 
                gutendexId: randomNumber,
                title: "Test Book \(randomNumber)",
                authors: ["Sample Author"], 
                localFilePath: "/dev/null/test_book_\(randomNumber).epub",
                coverImageURL: "https://placehold.co/120x180/7FFF00/000000?text=Test+\(randomNumber)", 
                sourceURL: "http://example.com/test\(randomNumber)",
                mediaType: "application/epub+zip"
            )
            self.fetchStoredBooks() 
        } catch {
            print("MyReadingsViewModel: Error adding sample book - \(error.localizedDescription)")
            self.errorMessage = "Failed to add sample book."
            isLoading = false 
        }
    }
}
