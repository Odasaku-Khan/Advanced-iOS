import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.userSession == nil {
                AccountView()
            } else {
                MainAppView()
            }
        }
    }
}


struct MainAppView: View {
    @EnvironmentObject var authViewModel: AuthViewModel


    var body: some View {
        TabView {
            MyReadingsView()
                .tabItem {
                    Label("Readings", systemImage: "book.fill")
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
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
