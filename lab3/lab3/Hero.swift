import Foundation

struct Hero: Codable, Identifiable { // Identifiable for SwiftUI lists
    let id: Int
    let name: String
    let slug: String
    let powerstats: PowerStats
    let appearance: Appearance
    let biography: Biography
    let connections: Connections
    let images: HeroImages

    // Add more properties as needed, at least 10 in total from the API

    struct PowerStats: Codable {
        let intelligence: Int?
        let strength: Int?
        let speed: Int?
        let durability: Int?
        let power: Int?
        let combat: Int?
    }

    struct Appearance: Codable {
        let gender: String?
        let race: String?
        let height: [String]?
        let weight: [String]?
        let eyeColor: String?
        let hairColor: String?
    }

    struct Biography: Codable {
        let fullName: String?
        let alterEgos: String?
        let aliases: [String]?
        let placeOfBirth: String?
        let firstAppearance: String?
        let publisher: String?
        let alignment: String?
    }
    struct Connections: Codable {
        let groupAffiliation: String?
        let relatives: String?
    }

    struct HeroImages: Codable {
        let xs: String?
        let sm: String?
        let md: String?
        let lg: String?
    }
}
