import Foundation
import Combine
import SwiftUI
import CoreData
@MainActor
class MyBooksViewModel:ObservableObject {
    @Published var books: [CoreDataBook] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    let context = PersistenceController.shared.container.viewContext
    
    func loadBooks(){
        let request: NSFetchRequest<CoreDataBook> = CoreDataBook.fetchRequest()
        
        do{
            books = try context.fetch(request)
        }catch{
            self.error = "Failed to load books: \(error.localizedDescription)"
        }
    }
    
    func fetchPublicBooks() async {
        guard let url = URL(string: "http://127.0.0.1:8080/public-books" )else{
            self.error = "Invalid URL"
            return
        }
        isLoading = true
        defer{isLoading = false}
        
        do{
            let (data,_) = try await URLSession.shared.data(from:url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let remoteBooks = try decoder.decode([Book].self, from: data)
            
            for book in remoteBooks {
                if !bookExist(id:book.id){
                    try await save(book:book)
                }
            }
            
            loadBooks()
            
        }catch{
            self.error = "Failed to fetch \(error.localizedDescription)"
        }
    }
    private func bookExist(id: UUID) ->Bool {
        let request: NSFetchRequest<CoreDataBook> = CoreDataBook.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let count = (try? context.count(for: request)) ?? 0
        return count>0
    }
    
    private func save(book:Book) async throws{
        let fileUrl = try await downloadFile(from:book.fileUrl,fileName:"\(book.id).fb2")
        
        let coreBook = CoreDataBook(context: context)
        coreBook.id = book.id
        coreBook.title = book.title
        coreBook.descriptionText = book.description
        coreBook.author = book.author
        coreBook.coverImagePath = book.coverImage
        coreBook.progress = Double(book.progress)
        coreBook.filePath = fileUrl.path
        try context.save()
    }
    
    private func downloadFile(from urlStr: String, fileName:String) async throws-> URL{
        guard let url = URL(string: urlStr) else{ throw URLError(.badURL)}
        let (data,_) = try await URLSession.shared.data(from: url)
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documents.appendingPathComponent(fileName)
        return fileURL
    }
}
