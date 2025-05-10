struct Book:Identifiable,Codable{
    var id:Int
    var title:String
    var author:String
    var coverImage:String
    let isAudioBook:Bool
    var progress:Float
    var description:String
}
