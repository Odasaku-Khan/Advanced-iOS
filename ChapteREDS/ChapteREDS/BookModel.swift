import Foundation

struct GutendexResults: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Book]
}

struct Book: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let authors: [Author]
    let subjects: [String]?
    let bookshelves: [String]?
    let languages: [String]?
    let copyright: Bool?
    let mediaType: String?
    let formats: BookFormats
    let downloadCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, authors, subjects, bookshelves, languages, copyright
        case mediaType = "media_type"
        case formats
        case downloadCount = "download_count"
    }
    
    // Conformance to Hashable
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Author: Codable, Hashable {
    let name: String
    let birthYear: Int?
    let deathYear: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case birthYear = "birth_year"
        case deathYear = "death_year"
    }
}

struct BookFormats: Codable, Hashable {
    let textHtml: String?
    let textPlain: String?
    let applicationEpubZip: String?
    let applicationMobiPocketbook: String?
    let applicationRdfXml: String?
    let imageJpeg: String? // For the book cover
    let textPlainCharsetUsAscii: String?
    let textPlainCharsetUtf8: String?
    let textHtmlCharsetUsAscii: String?
    let textHtmlCharsetUtf8: String?

    enum CodingKeys: String, CodingKey {
        case textHtml = "text/html"
        case textPlain = "text/plain"
        case applicationEpubZip = "application/epub+zip"
        case applicationMobiPocketbook = "application/x-mobipocket-ebook"
        case applicationRdfXml = "application/rdf+xml"
        case imageJpeg = "image/jpeg"
        case textPlainCharsetUsAscii = "text/plain; charset=us-ascii"
        case textPlainCharsetUtf8 = "text/plain; charset=utf-8"
        case textHtmlCharsetUsAscii = "text/html; charset=us-ascii"
        case textHtmlCharsetUtf8 = "text/html; charset=utf-8"
    }
}
