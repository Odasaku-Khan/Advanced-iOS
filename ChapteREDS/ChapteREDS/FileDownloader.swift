import Foundation

enum DownloadError: Error {
    case invalidURL
    case networkError(Error)
    case httpError(statusCode: Int)
    case noData
    case fileMoveError(Error)
    case directoryCreationError(Error)
    case missingSuggestedFilename
}

class FileDownloader {

    private func getDocumentsDirectory() throws -> URL {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: true)
            let booksDirectoryURL = documentsURL.appendingPathComponent("Books", isDirectory: true)
            if !FileManager.default.fileExists(atPath: booksDirectoryURL.path) {
                try FileManager.default.createDirectory(at: booksDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            return booksDirectoryURL
        } catch {
            print("FileDownloader: Error getting/creating documents or Books directory: \(error)")
            throw DownloadError.directoryCreationError(error)
        }
    }

    func downloadFile(from url: URL, bookId: Int, originalUrlString: String) async throws -> URL {
        print("FileDownloader: Starting download from \(url.absoluteString)")
        
        let (tempLocalURL, response) = try await URLSession.shared.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("FileDownloader: Response was not HTTPURLResponse.")
            throw DownloadError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("FileDownloader: HTTP Error. Status code: \(httpResponse.statusCode)")
            throw DownloadError.httpError(statusCode: httpResponse.statusCode)
        }
        
        var fileExtension = "dat"
        if let suggestedFilename = httpResponse.suggestedFilename {
            fileExtension = URL(fileURLWithPath: suggestedFilename).pathExtension
        } else if let mimeType = httpResponse.mimeType {
            if mimeType.contains("epub") {
                fileExtension = "epub"
            } else if mimeType.contains("plain") {
                fileExtension = "txt"
            } else if mimeType.contains("html") {
                fileExtension = "html"
            }
        } else {
             let originalPathExtension = URL(fileURLWithPath: originalUrlString).pathExtension
             if !originalPathExtension.isEmpty {
                 fileExtension = originalPathExtension
             }
        }
        if fileExtension.isEmpty { fileExtension = "dat" }

        let destinationDirectory = try getDocumentsDirectory()
        let uniqueFileName = "book_\(bookId).\(fileExtension)"
        let permanentFileURL = destinationDirectory.appendingPathComponent(uniqueFileName)

        print("FileDownloader: Moving file from \(tempLocalURL.path) to \(permanentFileURL.path)")
        
        if FileManager.default.fileExists(atPath: permanentFileURL.path) {
            try FileManager.default.removeItem(at: permanentFileURL)
        }

        do {
            try FileManager.default.moveItem(at: tempLocalURL, to: permanentFileURL)
            print("FileDownloader: File successfully downloaded and moved to \(permanentFileURL.path)")
            return permanentFileURL
        } catch {
            print("FileDownloader: Error moving file: \(error)")
            throw DownloadError.fileMoveError(error)
        }
    }
}
