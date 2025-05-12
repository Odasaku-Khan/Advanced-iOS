import SwiftUI

struct AccountProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("My Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            GIFView("default")
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                .padding(.bottom, 10)

            if let email = authViewModel.userSession?.email {
                Text(email)
                    .font(.title3)
                    .padding(.bottom, 20)
            }
            
            Button(action: {
                authViewModel.signOut()
            }) {
                Text("Sign Out")
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 40)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}
