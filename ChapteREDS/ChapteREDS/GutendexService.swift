import Foundation

enum GutendexError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int)
    case noData
}

class GutendexService {
    private let baseURL = "https://gutendex.com/books"
    private let decoder = JSONDecoder()

    func searchBooks(query: String, page: Int = 1) async throws -> GutendexResults {
        
        var components = URLComponents(string: baseURL)
        var queryItems = [URLQueryItem(name: "page", value: String(page))]

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedQuery.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))
        }
        
        components?.queryItems = queryItems

        guard let url = components?.url else {
            print("GutendexService: Invalid URL components: \(String(describing: components))")
            throw GutendexError.invalidURL
        }
        
        print("GutendexService: Fetching URL: \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw GutendexError.noData
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("GutendexService: Server error. Status code: \(httpResponse.statusCode)")
                print("GutendexService: Response data: \(String(data: data, encoding: .utf8) ?? "No response data")")
                throw GutendexError.serverError(statusCode: httpResponse.statusCode)
            }
            
            do {
                let decodedResponse = try decoder.decode(GutendexResults.self, from: data)
                print("GutendexService: Successfully decoded \(decodedResponse.results.count) books. Total count: \(decodedResponse.count).")
                return decodedResponse
            } catch {
                print("GutendexService: Decoding error: \(error)")
                print("GutendexService: Raw data string: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                throw GutendexError.decodingError(error)
            }
        } catch let error as GutendexError {
            throw error
        } catch {
            print("GutendexService: Network or other error: \(error)")
            throw GutendexError.networkError(error)
        }
    }
}
