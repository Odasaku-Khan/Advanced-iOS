import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let sampleData: [(id: Int64, title: String, authors: String, cover: String, media: String, source: String)] = [
            (101, "The Great Gatsby", "F. Scott Fitzgerald", "https://placehold.co/120x180/FF6347/FFFFFF?text=Gatsby", "application/epub+zip", "http://example.com/gatsby"),
            (102, "Moby Dick", "Herman Melville", "https://placehold.co/120x180/4682B4/FFFFFF?text=Moby+Dick", "application/epub+zip", "http://example.com/moby"),
            (103, "Pride and Prejudice", "Jane Austen", "https://placehold.co/120x180/32CD32/FFFFFF?text=Pride", "application/epub+zip", "http://example.com/pride")
        ]

        for item in sampleData {
            let newBook = StoredBook(context: viewContext)
            newBook.gutendexId = item.id
            newBook.title = item.title
            newBook.authors = item.authors
            newBook.downloadDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...60), to: Date())
            newBook.coverImageURL = item.cover
            newBook.localFilePath = "/dev/null/preview_\(item.id).epub"
            newBook.sourceURL = item.source
            newBook.mediaType = item.media
        }
        do {
            try viewContext.save()
            print("PersistenceController (Preview): Successfully saved \(sampleData.count) sample books for Veritas.")
        } catch {
            let nsError = error as NSError
            fatalError("PersistenceController (Preview) for Veritas: Unresolved error: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Veritas")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("PersistenceController for Veritas: Unresolved error: \(error), \(error.userInfo)")
            } else {
                print("PersistenceController for Veritas: Store loaded. URL: \(storeDescription.url?.absoluteString ?? "N/A")")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        print("PersistenceController for Veritas: Initialized. In-memory: \(inMemory)")
    }
}
