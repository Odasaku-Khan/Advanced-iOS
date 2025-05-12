
import Foundation
import Combine
@MainActor
class AuthViewModel:ObservableObject{
    @Published var email:String = ""
    @Published var password:String = ""
    @Published var isLoggedIn:Bool = true
    @Published var errorMessage:String?
    @Published var token:String?
    
    func toggleMode(){
        isLoggedIn.toggle()
    }
    struct AuthResponse:Decodable{
        let token:String
        let email:String
    }
    
    func authenticateUser() async throws -> AuthResponse{
        guard let url = URL(string: isLoggedIn ? "http://127.0.0.1:8080/auth/register": "http://127.0.0.1:8080/auth/login")else{
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body:[String:String]=[
            "email":email,
            "password":password
        ]
        request.httpBody = try JSONEncoder().encode(body)
        let (data,response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,(200..<300).contains(httpResponse.statusCode) else{
            throw URLError(.badServerResponse)
        }
        
        do{
            let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
            return decoded
        }catch{
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],let token = json["token"] as? String{
                return AuthResponse(token: token, email: email)
            }else{
                throw error
            }
        }
    }
}
