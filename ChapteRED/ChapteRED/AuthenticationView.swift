import SwiftUI

struct AuthenticationView: View {
    @StateObject var viewModel = AuthViewModel()
    @State private var isRegistering = false

    var body: some View {
        if viewModel.isAuthenticated {
            ContentView()
        } else {
            NavigationView {
                VStack {
                    Spacer()

                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 20)

                    Text(isRegistering ? "Create Account" : "Welcome Back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)

                    VStack(spacing: 15) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .disableAutocorrection(true)

                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }

                    Button(action: {
                        Task {
                            if isRegistering {
                                await viewModel.register()
                            } else {
                                await viewModel.login()
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        } else {
                            Text(isRegistering ? "Register" : "Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .disabled(viewModel.isLoading)

                    Button(action: {
                        isRegistering.toggle()
                        viewModel.errorMessage = nil
                    }) {
                        Text(isRegistering ? "Already have an account? Login" : "Don't have an account? Register")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .navigationBarHidden(true)
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
