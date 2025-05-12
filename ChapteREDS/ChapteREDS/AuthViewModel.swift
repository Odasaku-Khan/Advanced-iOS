import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading = false
    @Published var authError: String?

    init() {
        self.userSession = Auth.auth().currentUser
        if userSession != nil {
            print("AuthViewModel: User is already logged in with UID: \(userSession!.uid)")
        } else {
            print("AuthViewModel: No user logged in initially.")
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        authError = nil
        print("AuthViewModel: Attempting login with email: \(email)...")

        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = authResult.user
            print("AuthViewModel: Login successful. UID: \(self.userSession?.uid ?? "N/A")")
        } catch {
            print("AuthViewModel: Login failed: \(error.localizedDescription)")
            self.authError = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        authError = nil
        print("AuthViewModel: Attempting sign up with email: \(email)...")

        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = authResult.user
            print("AuthViewModel: Sign up successful. UID: \(self.userSession?.uid ?? "N/A")")
        } catch {
            print("AuthViewModel: Sign up failed: \(error.localizedDescription)")
            self.authError = error.localizedDescription
        }
        isLoading = false
    }
    
    func forgotPassword(email: String) async {
        isLoading = true
        authError = nil
        print("AuthViewModel: Sending password reset for email: \(email)...")
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("AuthViewModel: Password reset email sent.")
            self.authError = nil
        } catch {
            print("AuthViewModel: Failed to send password reset: \(error.localizedDescription)")
            self.authError = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            self.userSession = nil
            print("AuthViewModel: Signed out successfully from Firebase and Google.")
        } catch {
            print("AuthViewModel: Error signing out: \(error.localizedDescription)")
            self.authError = "Failed to sign out: \(error.localizedDescription)"
        }
    }

    
    func signInWithGoogle() async {
        isLoading = true
        authError = nil
        print("AuthViewModel: Attempting Google Sign-In...")

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("AuthViewModel: Firebase client ID not found.")
            self.authError = "Firebase client ID not found."
            isLoading = false
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config // It's good practice to set this if not set globally
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("AuthViewModel: Could not get root view controller for Google Sign-In.")
            self.authError = "Could not initiate Google Sign-In."
            isLoading = false
            return
        }

        do {
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = gidSignInResult.user.idToken?.tokenString else {
                print("AuthViewModel: Google ID token not found.")
                self.authError = "Google ID token not found."
                isLoading = false
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: gidSignInResult.user.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            self.userSession = authResult.user
            print("AuthViewModel: Google Sign-In successful. UID: \(self.userSession?.uid ?? "N/A")")
            
        } catch {
            print("AuthViewModel: Google Sign-In failed: \(error.localizedDescription)")
            if error.localizedDescription.contains("canceled") { // A more specific check might be GIDSignInError.Code.canceled.rawValue
                self.authError = "Google Sign-In was cancelled."
            } else {
                self.authError = error.localizedDescription
            }
        }
        isLoading = false
    }
}
