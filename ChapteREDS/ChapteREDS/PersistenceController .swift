import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample StoredBook objects
        for i in 0..<5 { // Let's create 5 sample books
            let newBook = StoredBook(context: viewContext)
            newBook.gutendexId = Int64(1000 + i) // Sample unique ID
            newBook.title = "Sample Book Title \(i + 1)"
            newBook.authors = "Author A, Author B"
            newBook.localFilePath = "/path/to/sample/book\(i+1).epub" // Placeholder path
            newBook.coverImageURL = "https://example.com/cover\(i+1).jpg" // Placeholder URL
            newBook.downloadDate = Date().addingTimeInterval(Double(-i * 3600)) // Vary download dates
            newBook.sourceURL = "https://gutendex.com/books/\(1000+i)" // Placeholder source
            newBook.mediaType = "application/epub+zip"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ChapteREDS")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
