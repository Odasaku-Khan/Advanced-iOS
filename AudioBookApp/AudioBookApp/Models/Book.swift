import Foundation
struct Book:Identifiable,Codable{
    var id:UUID
    var title:String
    var author:String
    var coverImage:String
    let isAudioBook:Bool
    var progress:Float
    var description:String
    var fileUrl: String
}
