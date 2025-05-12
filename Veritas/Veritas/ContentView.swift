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
        .onAppear {
            print("ContentView: Appeared. User session: \(authViewModel.userSession ?? "nil")")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        
        return ContentView()
            .environmentObject(authViewModel)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
