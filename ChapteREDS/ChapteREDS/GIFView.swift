import SwiftUI
import WebKit

struct GIFView: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear

        guard let url = Bundle.main.url(forResource: name, withExtension: "gif") else {
            print("GIFView ERROR: GIF file '\(name).gif' not found in bundle.")
            return webView
        }

        do {
            let data = try Data(contentsOf: url)
            let base64String = data.base64EncodedString()
            let htmlString = """
            <html>
            <head>
                <style>
                    body {
                        margin: 0;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        width: 100%;
                        height: 100%;
                    }
                    img {
                        object-fit: cover; 
                        width: 100%;
                        height: 100%;
                    }
                </style>
            </head>
            <body>
                <img src="data:image/gif;base64,\(base64String)" />
            </body>
            </html>
            """
            webView.loadHTMLString(htmlString, baseURL: nil)
            print("GIFView: Loaded GIF as Base64 HTML string.")
        } catch {
            print("GIFView ERROR: Could not load data or create Base64 string: \(error)")
        }
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
