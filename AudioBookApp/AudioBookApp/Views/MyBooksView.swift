import SwiftUI
import Foundation
import Combine
import CoreData

struct LoadingBooksView: View{
    var body: some View{
        ProgressView("Loading Books")
    }
}

struct BooksErrorView: View{
    var error: Error
    var body: some View{
        Text("Error: \(error.localizedDescription)")
            .foregroundColor(.red)
    }
}

struct BookListView:View {
    @ObservedObject var viewModel: MyBooksViewModel
    var body: some View {
        List{
            ForEach(viewModel.books, id: \.objectID){ book in
                BookRowView(book:book)
            }
        }
        
    }
}

struct BookRowView: View {
    let book: CoreDataBook
    
    var body: some View{
        NavigationLink(destination: BookDetailView(book: book)){
            VStack(alignment:.leading, spacing: 8){
                Text(book.title ?? "Untitled").font(.headline)
                Text(book.author ?? "Unknown").font(.subheadline).foregroundColor(.secondary)
                ProgressView(value: book.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint:.blue))
                    .frame(height:6)
                Text("\(Int((book.progress)*100))% read")
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }
            .padding(.vertical)
        }
    }
}


struct MyBooksView: View {
    @EnvironmentObject var session: UserSession
    @StateObject private var viewModel = MyBooksViewModel()

    // Computed property to handle conditional view rendering
    private var contentView: some View {
        Group{
            if viewModel.isLoading{
                LoadingBooksView()
            }else if let error = viewModel.error{
                BooksErrorView(error:error as! Error)
            }else{
                BookListView(viewModel: viewModel)
            }
        }
    }

    var body: some View{
        NavigationView(){
            contentView
            .navigationTitle("My Books")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button{
                        Task{
                            await viewModel.fetchPublicBooks()
                        }
                    }label:{
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3)

                    }
                    .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .navigationBarLeading){
                    NavigationLink(destination: UploadBookView(viewModel:viewModel)){
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)

                    }
                }
            }
            .onAppear{
                viewModel.loadBooks()
            }
        }
    }
}
//#Preview {
//    MyBooksView()
//        .environmentObject(UserSession())
//}
