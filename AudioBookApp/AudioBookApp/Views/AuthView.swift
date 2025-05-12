import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: UserSession
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing:20){
                Text(viewModel.isLoggedIn ? "Login" : "Register" )
                    .font(.title)
                    .bold()
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.secondary.opacity(0.3))
                    .cornerRadius(8)
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color.secondary.opacity(0.3))
                    .cornerRadius(8)
                Button(action: {
                    Task{
                        do{
                            let response = try await viewModel.authenticateUser()
                            session.token = response.token
                            session.email = response.email
                            session.isLoggedIn = true
                        }catch{
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                }){
                    Text(viewModel.isLoggedIn ? "Login" : "Register ")
                        .bold()
                        .frame(maxWidth:.infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                Button(viewModel.isLoggedIn ? "Don't have account? Register" : "Already have an Account? Login"){
                    viewModel.toggleMode()
                }
                .padding(.top)
                if let error = viewModel.errorMessage{
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
    }
}
#Preview {
    AuthView()
}
