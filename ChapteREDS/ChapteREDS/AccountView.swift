import SwiftUI

struct AccountView: View {
    @EnvironmentObject var viewModel: AuthViewModel // Changed from @StateObject

    enum AuthMode {
        case login, signUp
    }
    @State private var authMode: AuthMode = .login

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var mainButtonText: String {
        authMode == .login ? "Login" : "Sign Up"
    }

    private var switchModeButtonText: String {
        authMode == .login ? "Don't have an account? Sign up" : "Already have an account? Login"
    }
    
    private func submitForm() {
        if authMode == .login {
            Task {
                await viewModel.login(email: email, password: password)
            }
        } else {
            if password == confirmPassword {
                Task {
                    await viewModel.signUp(email: email, password: password)
                }
            } else {
                viewModel.authError = "Passwords do not match."
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()

                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                Text(authMode == .login ? "Welcome Back!" : "Create Account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )

                if authMode == .signUp {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                
                if let errorMessage = viewModel.authError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.vertical, 5)
                        .multilineTextAlignment(.center)
                }

                Button(action: submitForm) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    } else {
                        Text(mainButtonText)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .disabled(viewModel.isLoading)
                .padding(.top, 5)
                
                if authMode == .login {
                    Button(action: {
                        if !email.isEmpty {
                            Task {
                                await viewModel.forgotPassword(email: email)
                            }
                        } else {
                            viewModel.authError = "Please enter your email address for password reset."
                        }
                    }) {
                        Text("Forgot password?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }

                Button(action: {
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Sign in with Google")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.primary)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.7), lineWidth: 1)
                    )
                }
                .disabled(viewModel.isLoading)
                .padding(.top, authMode == .login ? 5 : 20)

                Spacer()

                Button(action: {
                    authMode = (authMode == .login) ? .signUp : .login
                    viewModel.authError = nil
                    confirmPassword = ""
                }) {
                    Text(switchModeButtonText)
                        .fontWeight(.semibold)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 20)

            }
            .padding(.horizontal, 30)
            .navigationBarHidden(true)
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(AuthViewModel()) // Ensure preview also gets the environment object
            .preferredColorScheme(.dark)
            .previewDisplayName("Login Mode")
    }
}
