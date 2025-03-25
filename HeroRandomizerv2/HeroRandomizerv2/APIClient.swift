import Foundation

struct APIClient {
    static func fetchRandomHero() async throws -> Hero {
        let apiURLString = "https://akabab.github.io/superhero-api/api/all.json"
        guard let apiURL = URL(string: apiURLString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: apiURL)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let allHeroes = try decoder.decode([Hero].self, from: data)

        guard let randomHero = allHeroes.randomElement() else {
            throw NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get a random hero"])
        }
        return randomHero
    }
}
