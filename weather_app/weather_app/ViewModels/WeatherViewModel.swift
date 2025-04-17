import Foundation

@MainActor
class WeatherViewModel:ObservableObject{
    @Published var currentWeather:CurrentWeather?
    @Published var isLoading:Bool = false
    @Published var error:String?
    @Published var city: String = "Almaty"
    func loadWeather(for city:String){
        Task{
            isLoading = true
            error = nil
            do {
                currentWeather=try await WeatherAPIService.shared.fetchCurrentWeather(for: city)
            }catch {
                self.error = "Failed to load :\(error.localizedDescription)"
            }
            isLoading=false
        }
    }
    
}
