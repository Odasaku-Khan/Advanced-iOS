import CoreData
import SwiftUI

struct BookStorageService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        print("BookStorageService: Initialized.")
    }

    func saveBook(
        gutendexId: Int64,
        title: String,
        authors: [String],
        localFilePath: String,
        coverImageURL: String?,
        sourceURL: String,
        mediaType: String?
    ) throws {
        let fetchRequest: NSFetchRequest<StoredBook> = StoredBook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "gutendexId == %lld", gutendexId)
        fetchRequest.fetchLimit = 1

        do {
            let existingBooks = try context.fetch(fetchRequest)
            let bookToSave: StoredBook
            if let existingBook = existingBooks.first {
                print("BookStorageService: Book with gutendexId \(gutendexId) already exists. Updating its details.")
                bookToSave = existingBook
            } else {
                print("BookStorageService: Saving new book with gutendexId \(gutendexId).")
                bookToSave = StoredBook(context: context)
                bookToSave.gutendexId = gutendexId
            }

            bookToSave.title = title
            bookToSave.authors = authors.joined(separator: ", ")
            bookToSave.localFilePath = localFilePath
            bookToSave.coverImageURL = coverImageURL
            bookToSave.downloadDate = Date()
            bookToSave.sourceURL = sourceURL
            bookToSave.mediaType = mediaType
            
            try context.save()
            print("BookStorageService: Successfully saved/updated book \(title).")
        } catch {
            print("BookStorageService: Failed to save or fetch book with gutendexId \(gutendexId): \(error)")
            context.rollback()
            throw error
        }
    }

    func fetchStoredBooks() -> [StoredBook] {
        let request: NSFetchRequest<StoredBook> = StoredBook.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StoredBook.downloadDate, ascending: false)]
        do {
            let books = try context.fetch(request)
            print("BookStorageService: Fetched \(books.count) stored books.")
            return books
        } catch {
            print("BookStorageService: Error fetching books - \(error.localizedDescription)")
            return []
        }
    }

    func fetchDownloadedBookIDs() -> Set<Int> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = StoredBook.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        
        let idExpressionDescription = NSExpressionDescription()
        idExpressionDescription.name = "gutendexId_dictKey"
        idExpressionDescription.expression = NSExpression(forKeyPath: \StoredBook.gutendexId)
        idExpressionDescription.expressionResultType = .integer64AttributeType
        
        fetchRequest.propertiesToFetch = [idExpressionDescription]
            
        var ids = Set<Int>()
        do {
            if let results = try context.fetch(fetchRequest) as? [NSDictionary] {
                for dict in results {
                    if let idValue = dict["gutendexId_dictKey"] as? Int64 {
                        ids.insert(Int(idValue))
                    } else if let idValue = dict["gutendexId"] as? Int64 {
                        ids.insert(Int(idValue))
                    }
                }
            }
            print("BookStorageService: Fetched \(ids.count) downloaded book IDs.")
        } catch {
            print("BookStorageService: Failed to fetch downloaded book IDs: \(error)")
        }
        return ids
    }

    func isBookDownloaded(gutendexId: Int64) -> Bool {
        let fetchRequest: NSFetchRequest<StoredBook> = StoredBook.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "gutendexId == %lld", gutendexId)
        fetchRequest.fetchLimit = 1

        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("BookStorageService: Error checking if book is downloaded (gutendexId: \(gutendexId)): \(error)")
            return false
        }
    }
    
    func deleteBook(storedBook: StoredBook) throws {
        let bookTitle = storedBook.title ?? "Unknown"
        let bookID = storedBook.gutendexId
        print("BookStorageService: Deleting book titled '\(bookTitle)' with gutendexId \(bookID).")

        if let filePath = storedBook.localFilePath {
            let fileURL = URL(fileURLWithPath: filePath)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("BookStorageService: Successfully deleted file at \(filePath).")
                } catch {
                    print("BookStorageService: Failed to delete file at \(filePath): \(error). Proceeding to delete Core Data entry.")
                }
            } else {
                print("BookStorageService: File not found at \(filePath), cannot delete. Proceeding to delete Core Data entry.")
            }
        }
        
        context.delete(storedBook)
        do {
            try context.save()
            print("BookStorageService: Successfully deleted Core Data entry for book gutendexId \(bookID).")
        } catch {
            print("BookStorageService: Failed to save context after deleting book gutendexId \(bookID): \(error).")
            context.rollback()
            throw error
        }
    }
}
