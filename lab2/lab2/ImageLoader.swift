import Foundation
import UIKit

// Part 1: Memory Management Implementation - Image Loading System

protocol ImageLoaderDelegate: AnyObject { // Restrict to reference types
    func imageLoader(_ loader: ImageLoader, didLoad image: UIImage)
    func imageLoader(_ loader: ImageLoader, didFailWith error: Error)
}

class ImageLoader {
    weak var delegate: ImageLoaderDelegate? // Weak delegate to prevent retain cycle
    var completionHandler: ((UIImage?) -> Void)?

    func loadImage(url: URL) {
        DispatchQueue.global().async { [weak self] in // Capture self weakly to avoid retain cycle
            // Simulate image loading
            Thread.sleep(forTimeInterval: 0.5)
            let image = UIImage() // Placeholder image
            DispatchQueue.main.async {
                self?.delegate?.imageLoader(self!, didLoad: image) // Delegate call - weak delegate
                self?.completionHandler?(image) // Closure call - no retain cycle concern here unless self is strongly captured in completionHandler's implementation outside of ImageLoader
            }
        }
    }
}

class PostView: UIView, ImageLoaderDelegate { // Conform to ImageLoaderDelegate
    weak var imageLoader: ImageLoader? // Weak reference if PostView does not own ImageLoader

    func setupImageLoader() {
        let loader = ImageLoader()
        imageLoader = loader // Assign weak reference
        loader.delegate = self // Set delegate - weak delegate in ImageLoader prevents cycle
        loader.completionHandler = { [weak self] image in // Capture self weakly in closure
            if let image = image {
                print("Image loaded via closure in PostView")
                // Update imageView with loaded image
            }
        }
    }

    func loadImageForPost(imageUrl: URL) {
        imageLoader?.loadImage(url: imageUrl)
    }

    // ImageLoaderDelegate methods
    func imageLoader(_ loader: ImageLoader, didLoad image: UIImage) {
        print("Delegate method called: Image loaded in PostView")
        // Update imageView with loaded image
    }

    func imageLoader(_ loader: ImageLoader, didFailWith error: Error) {
        print("Delegate method called: Image loading failed in PostView: \(error.localizedDescription)")
        // Handle image loading error
    }
}
