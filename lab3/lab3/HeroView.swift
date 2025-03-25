import SwiftUI
import APIClient
import Hero

struct HeroView: View {
    @State private var hero: Hero? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Summoning Hero...")
            } else if let hero = hero {
                ScrollView { // Make content scrollable if attributes are many
                    VStack(alignment: .leading) {
                        Text(hero.name)
                            .font(.largeTitle)
                            .padding(.bottom, 8)

                        // Display at least 10 attributes - Example attributes:
                        attributeView(title: "Full Name", value: hero.biography.fullName)
                        attributeView(title: "Aliases", value: hero.biography.aliases?.joined(separator: ", "))
                        attributeView(title: "Gender", value: hero.appearance.gender)
                        attributeView(title: "Race", value: hero.appearance.race)
                        attributeView(title: "Eye Color", value: hero.appearance.eyeColor)
                        attributeView(title: "Hair Color", value: hero.appearance.hairColor)
                        attributeView(title: "Intelligence", value: hero.powerstats.intelligence)
                        attributeView(title: "Strength", value: hero.powerstats.strength)
                        attributeView(title: "Speed", value: hero.powerstats.speed)
                        attributeView(title: "Durability", value: hero.powerstats.durability)
                        attributeView(title: "Combat", value: hero.powerstats.combat)


                        // ... Add more attributes as needed ...
                    }
                    .padding()
                }
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("Tap 'Summon Hero' to begin!")
                    .padding()
            }

            Button("Summon Hero") {
                Task { // Use Task for async operations in SwiftUI
                    await fetchNewHero()
                }
            }
            .padding()
            .buttonStyle(.borderedProminent) // For better visual style
        }
        .padding()
    }

    // Helper view for displaying attributes
    private func attributeView(title: String, value: String?) -> some View {
        VStack(alignment: .leading) {
            Text("\(title):")
                .font(.headline)
            Text(value ?? "N/A") // Display "N/A" if value is nil
                .padding(.bottom, 4)
        }
    }

    private func attributeView(title: String, value: Int?) -> some View { // Overload for Int values
        VStack(alignment: .leading) {
            Text("\(title):")
                .font(.headline)
            Text(value?.description ?? "N/A") // Display "N/A" if value is nil
                .padding(.bottom, 4)
        }
    }


    // Function to fetch a new hero
    private func fetchNewHero() async {
        isLoading = true
        errorMessage = nil // Clear any previous error
        do {
            hero = try await APIClient.fetchRandomHero()
        } catch {
            errorMessage = error.localizedDescription
            hero = nil // Clear previous hero on error
        }
        isLoading = false
    }
}
