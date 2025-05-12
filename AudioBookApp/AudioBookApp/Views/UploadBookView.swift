import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct UploadBookView: View {
    @EnvironmentObject var session: UserSession
    @ObservedObject var viewModel: MyBooksViewModel // Changed to ObservedObject

    @State private var isDocumentPickerPresented: Bool = false
    @State private var selectedFileURL: URL?
    @State private var isPublic: Bool = false
    @State private var uploadProgress: Double = 0 // Not real-time without delegate
    @State private var uploadError: String?
    @State private var showUploadSuccessAlert: Bool = false // State for success feedback

    var body: some View {
        VStack {
            if let url = selectedFileURL {
                Text("Selected File: \(url.lastPathComponent)")
                    .padding(.bottom)
            } else {
                Text("No file selected")
                    .padding(.bottom)
            }

            Button("Select Book File") {
                isDocumentPickerPresented = true
            }
            // Update allowedUTIs to match upload logic (FB2, MP3)
            .sheet(isPresented: $isDocumentPickerPresented) {
                DocumentPicker(selectedFileURL: $selectedFileURL, allowedUTIs: ["public.fb2", UTType.mp3.identifier])
            }
            .padding(.bottom)

            Toggle("Public Book", isOn: $isPublic)
                .padding(.bottom)

            Button("Upload Book") {
                if let fileURL = selectedFileURL {
                    Task {
                        await uploadBook(from: fileURL)
                    }
                } else {
                    uploadError = "Please select a file first."
                }
            }
            .disabled(selectedFileURL == nil)
            .padding(.bottom)

            if let error = uploadError {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding(.bottom)
            }

            ProgressView(value: uploadProgress)
                .padding(.bottom)

            Spacer() // Push content up
        }
        .padding()
        .navigationTitle("Upload Book")
        // Alert for successful upload
        .alert("Upload Successful!", isPresented: $showUploadSuccessAlert) {
            Button("OK") {
                // Action after success
            }
        } message: {
            Text("Your book has been uploaded successfully.")
        }
    }

    func uploadBook(from fileURL: URL) async {
        // Reset state
        uploadError = nil
        uploadProgress = 0.0
        showUploadSuccessAlert = false

        guard let fileData = try? Data(contentsOf: fileURL) else {
            uploadError = "Failed to read file data."
            return
        }

        let fileExtension = fileURL.pathExtension.lowercased()
        var endpoint: String = ""

        if fileExtension == "fb2" {
            endpoint = "upload-fb2"
        } else if fileExtension == "mp3" {
            endpoint = "upload-mp3"
        } else {
            uploadError = "Unsupported file format. Please select an FB2 or MP3 file."
            return
        }

        guard let uploadURL = URL(string: "http://127.0.0.1:8080/auth/\(endpoint)") else {
            uploadError = "Invalid upload URL."
            return
        }

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let token = session.token else {
            uploadError = "Not authenticated."
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var httpBody = Data()

        // Add file part
        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        httpBody.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!) // Corrected double \r\n
        httpBody.append(fileData)
        httpBody.append("\r\n".data(using: .utf8)!)

        // Add isPublic part
        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"isPublic\"\r\n\r\n".data(using: .utf8)!) // Corrected double \r\n
        httpBody.append("\(isPublic)".data(using: .utf8)!) // Convert boolean to string
        httpBody.append("\r\n".data(using: .utf8)!)

        // End of body
        httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = httpBody

        do {
            // Using data(for:) for simplicity without progress delegate
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                         // await viewModel.loadBooks() // Await is valid if loadBooks is async
                         selectedFileURL = nil
                         uploadError = nil
                         uploadProgress = 1.0 // Indicate completion
                         showUploadSuccessAlert = true // Show success alert
                    }
                } else {
                    // Handle HTTP errors
                    let responseString = String(data: data, encoding: .utf8) ?? "No response data"
                    DispatchQueue.main.async {
                         uploadError = "Upload failed: Status \(httpResponse.statusCode). \(responseString)"
                         uploadProgress = 0.0 // Reset progress
                    }
                }
            } else {
                // Handle non-HTTP responses
                DispatchQueue.main.async {
                    uploadError = "No response from server"
                    uploadProgress = 0.0
                }
            }
        } catch {
            // Handle network or other errors
            DispatchQueue.main.async {
                 uploadError = "Error uploading file: \(error.localizedDescription)"
                 uploadProgress = 0.0
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileURL: URL?
    let allowedUTIs: [String]

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let utTypes = allowedUTIs.compactMap { UTType($0) }
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: utTypes, asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedURL = urls.first else { return }
            self.parent.selectedFileURL = selectedURL
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle cancellation
        }
    }
}
