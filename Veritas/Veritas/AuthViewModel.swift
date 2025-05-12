import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: String? = nil 

    func signIn(user: String = "TestUser") {
        self.userSession = user
        print("AuthViewModel: User signed in - \(user)")
    }

    func signOut() {
        self.userSession = nil
        print("AuthViewModel: User signed out.")
    }

    init() {
        print("AuthViewModel: Initialized.")
    }
}
