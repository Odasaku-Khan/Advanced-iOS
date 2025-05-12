import SwiftUI

struct AccountProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)

                if let user = authViewModel.userSession {
                    Text("Logged in as:")
                        .font(.headline)
                    Text(user)
                        .font(.title2)
                        .fontWeight(.semibold)
                } else {
                    Text("Not Logged In")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                
                Spacer() 

                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 40)
                .padding(.bottom, 30) 
            }
            .navigationTitle("My Account")
        }
        .navigationViewStyle(.stack)
    }
}

struct AccountProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        return AccountProfileView()
            .environmentObject(authViewModel)
    }
}
