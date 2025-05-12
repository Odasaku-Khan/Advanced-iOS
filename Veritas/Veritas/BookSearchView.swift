import SwiftUI

struct BookSearchView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.accentColor) 
                Text("Book Search")
                    .font(.title)
                Text("Implement your book search functionality here for Veritas.\n(e.g., using a search bar and API calls)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Search Books")
        }
        .navigationViewStyle(.stack)
    }
}

struct BookSearchView_Previews: PreviewProvider {
    static var previews: some View {
        BookSearchView()
    }
}
