import SwiftUI

struct MainAppView: View {
    var body: some View {
        TabView { 
            MyReadingsView() 
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }

            BookSearchView() 
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            AccountProfileView() 
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
        }
        .onAppear{
            print("MainAppView: Appeared.")
        }
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
            .environmentObject(AuthViewModel()) 
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext) 
    }
}
