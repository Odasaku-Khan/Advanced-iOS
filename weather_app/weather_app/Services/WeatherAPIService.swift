import Foundation

class WeatherAPIService {
    static let shared   = WeatherAPIService()
    private let apiKey="4414a6f4b9482db5b50170ae620c5ee9"
    
    func fetchCurrentWeather(for city:String) async throws-> CurrentWeather{
        let urlString="https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        guard let url=URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data,_) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(CurrentWeather.self, from: data)
    }
}
