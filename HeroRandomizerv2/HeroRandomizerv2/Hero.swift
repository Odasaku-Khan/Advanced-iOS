import Foundation

struct Hero: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let powerstats: PowerStats
    let appearance: Appearance
    let biography: Biography
    let connections: Connections
    let images: HeroImages

    struct PowerStats: Codable {
        let intelligence, strength, speed, durability, power, combat: Int?
    }

    struct Appearance: Codable {
        let gender, race, eyeColor, hairColor: String?
    }

    struct Biography: Codable {
        let fullName, alterEgos, placeOfBirth, firstAppearance, publisher, alignment: String?
        let aliases: [String]?
    }

    struct Connections: Codable {
        let groupAffiliation, relatives: String?
    }

    struct HeroImages: Codable {
        let lg: String?
    }
}
