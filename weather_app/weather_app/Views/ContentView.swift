
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel=WeatherViewModel()
    var body: some View {
        VStack(spacing:20){
            HStack{
                TextField("Enter city",text:$viewModel.city).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("search"){
                    viewModel.loadWeather(for: viewModel.city)
                }
            }
            if viewModel.isLoading{
                ProgressView("Loading...")
            }else if let weather=viewModel.currentWeather{
                Text("\(weather.name)")
                Text("\(weather.main.temp, specifier: "%.1f")°C")
                Text(weather.weather.first?.description.capitalized ?? "No Description")
                if let icon=weather.weather.first?.icon{
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) {image in image
                            .image?.resizable()
                            .scaledToFit()
                        .frame(width: 100,height:100)}
                }
            }else if let error=viewModel.error{
                Text("\(error)").foregroundColor(.red)
            }
            
            Button("Refresh"){
                viewModel.loadWeather(for: viewModel.city)
            }
        }
        .onAppear{
            viewModel.loadWeather(for: "Almaty")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
