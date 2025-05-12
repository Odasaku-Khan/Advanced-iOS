import Combine

class UserSession:ObservableObject{
    @Published var token:String? = nil
    @Published var email:String? = ""
    @Published var isLoggedIn:Bool = false
    
    func logout(){
        token = nil
        email = ""
        isLoggedIn = false
    }
    
}
