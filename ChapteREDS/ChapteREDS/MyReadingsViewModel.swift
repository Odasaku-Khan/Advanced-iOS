import SwiftUI
import Combine
import CoreData

@MainActor
class MyReadingsViewModel: ObservableObject {
    @Published var storeBook:[StoredBook]=[]
    @Published var isLoading:Bool=false
    @Published var errorMessage:String? = nil
    
    private let bookStorageService:BookStorageService
    private var cancellables=Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext =  PersistenceController.shared.container.viewContext){
        self.bookStorageService=BookStorageService(context: context)
        fetchStoredBooks()
    }
    func fetchStoredBooks(){
        isLoading=true
        errorMessage=nil
        let fetchBooks = bookStorageService.fetchStoredBooks()
        self.storeBook = fetchBooks.sorted{
            ($0.downloadDate ?? Date.distantPast) > ($1.downloadDate ?? Date.distantPast)
        }
        isLoading=false
        
        if self.storeBook.isEmpty{
            print("No book")
        }
    }
    func deleteBook(at indexSet: IndexSet){
        isLoading = true
        errorMessage = nil
        
        let bookToDelete = indexSet.map{self.storeBook[$0]}
        Task{
            for book in bookToDelete{
                do{
                    try self.bookStorageService.deleteBook(storedBook: book)
                }catch{
                    print("Delete Error \(error)")
                }
            }
        }
        
        
        fetchStoredBooks()
    }
    
    
    
    
    
}
