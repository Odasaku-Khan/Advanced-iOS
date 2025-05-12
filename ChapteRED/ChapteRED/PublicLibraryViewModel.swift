import SwiftUI
import CoreData
import UniformTypeIdentifiers
import MobileCoreServices
import FirebaseAuth

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authViewModel: AuthViewModel

    @FetchRequest var books: FetchedResults<Book>

    @State private var showingDocumentPicker = false
    @State private var importError: String?
    @State private var showingImportErrorAlert = false

    init() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            _books = FetchRequest<Book>(
                sortDescriptors: [NSSortDescriptor(keyPath: \Book.dateAdded, ascending: false)],
                predicate: NSPredicate(format: "userID == %@", "INVALID_USER_ID"),
                animation: .default
            )
            return
        }

        _books = FetchRequest<Book>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Book.dateAdded, ascending: false)],
            predicate: NSPredicate(format: "userID == %@", currentUserID),
            animation: .default
        )
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(books) { book in
                    NavigationLink {
                        Text("Read: \(book.title ?? "Unknown Title")")
                    } label: {
                        HStack {
                            Image(systemName: "book.closed")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 5)
                            VStack(alignment: .leading) {
                                Text(book.title ?? "Unknown Title")
                                    .font(.headline)
                                Text(book.author ?? "Unknown Author")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteBooks)
            }
            .navigationTitle("My Books")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingDocumentPicker = true
                    } label: {
                        Label("Import Book", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker(onDocumentPicked: handleDocumentPicked)
            }
            .alert(isPresented: $showingImportErrorAlert) {
                Alert(title: Text("Import Error"), message: Text(importError ?? "An unknown error occurred."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func deleteBooks(offsets: IndexSet) {
        withAnimation {
            offsets.map { books[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }

    private func handleDocumentPicked(url: URL?) {
        print("handleDocumentPicked called with URL: \(url?.absoluteString ?? "nil")")
        guard let url = url else {
            print("handleDocumentPicked: URL is nil, likely cancelled.")
            return
        }

        let success = url.startAccessingSecurityScopedResource()
        defer {
            url.stopAccessingSecurityScopedResource()
            print("Stopped accessing security scoped resource.")
        }

        if success {
            print("Successfully started accessing security scoped resource.")
            do {
                let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)

                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try? FileManager.default.removeItem(at: destinationURL)
                    print("Removed existing file at destination.")
                }

                try FileManager.default.copyItem(at: url, to: destinationURL)
                print("Copied file to destination: \(destinationURL.path)")


                let fileName = destinationURL.lastPathComponent
                let title = fileName.replacingOccurrences(of: ".epub", with: "", options: [.caseInsensitive])
                let author = "Unknown Author"

                let newBook = Book(context: viewContext)
                newBook.title = title
                newBook.author = author
                newBook.filePath = destinationURL.path
                newBook.dateAdded = Date()
                newBook.lastReadLocation = ""
                // Note: userID should be set here as well, similar to PublicLibraryViewModel
                // For MVP simplicity, we might skip for now or add later.

                saveContext()
                print("Book saved to Core Data.")


            } catch {
                importError = "Failed to import book: \(error.localizedDescription)"
                showingImportErrorAlert = true
                print("Error during file operations: \(error.localizedDescription)")
            }
        } else {
            importError = "Could not access the selected file."
            showingImportErrorAlert = true
            print("Failed to start accessing security scoped resource.")
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving Core Data context: \(nsError), \(nsError.userInfo)")
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var onDocumentPicked: (URL?) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [UTType.epub]

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("Document picker didPickDocumentsAt: \(urls.first?.absoluteString ?? "nil")")
            parent.onDocumentPicked(urls.first)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled.")
            parent.onDocumentPicked(nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AuthViewModel())
    }
}
