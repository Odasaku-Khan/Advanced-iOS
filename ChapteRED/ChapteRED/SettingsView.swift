import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                    .padding()

                Text("Settings")
                    .font(.largeTitle)
                    .padding(.bottom, 20)

                if let userEmail = Auth.auth().currentUser?.email {
                    Text("Logged in as:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(userEmail)
                        .font(.title2)
                        .padding(.bottom, 20)
                }

                Button("Logout") {
                    Task {
                        await authViewModel.logout()
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
