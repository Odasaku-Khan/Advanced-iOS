import Foundation
struct Main:Decodable {
    let temp:Double
}
struct CurrentWeather:Decodable {
    let name:String
    let main:Main
    let weather:[Weather]
}
struct Weather:Decodable{
    let description:String
    let icon:String
}
