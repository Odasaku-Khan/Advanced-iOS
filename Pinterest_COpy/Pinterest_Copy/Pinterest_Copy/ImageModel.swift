import Foundation
struct ImageModel: Identifiable{
    let id=UUID()
    let url:String
    init(url: String){
        self.url=url
    }
}
