import SwiftUI
import Foundation
import CoreData

struct BookDetailView: View {
    let book: CoreDataBook

    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            Text(book.title ?? "Untitled").font(.title).bold()
            Text("by \(book.author ?? "Unknown")").font(.subheadline)
            Text(book.descriptionText ?? "No description").padding()

            if let fileURLString = book.filePath, let url = URL(string: "http://127.0.0.1:8080\(fileURLString)"){
                Link("Download Book", destination: url)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }else{
                Text("Download not available")
                    .foregroundColor(.gray)             }
            Spacer()

        }
        .padding()
        .navigationBarTitle(book.title ?? "Book Detail", displayMode: .inline)
    }
}
