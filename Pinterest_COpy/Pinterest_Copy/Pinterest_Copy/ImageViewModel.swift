import Foundation
class ImageViewModel:ObservableObject{
    @Published var images:[ImageModel]=[]
    private let imageAPI="https://picsum.photos/300/400"
    func fetchImage(){
        var newImage:[ImageModel]=[]
        let group=DispatchGroup()
        for _ in 0..<10{
            group.enter()
            guard let url=URL(string:imageAPI)else{
                print("Invalid UrL")
                group.leave()
                continue
            }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse,
                   let urlString = httpResponse.url?.absoluteString {
                    let image=ImageModel(url: urlString)
                    newImage.append(image)
                } else {
                    print("Error fetching image URL")
                }
                group.leave()
            }.resume()
        }
        group.notify(queue: .main) {
            self.images.append(contentsOf: newImage)
        }
    }
}
