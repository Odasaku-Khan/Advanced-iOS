import Foundation
import SwiftUI

struct DetailedView: View {
    let image:ImageModel
    var body: some View {
        VStack{
            AsyncImage(url: URL(string: image.url)){ image in
                image.resizable()
                    .scaledToFit()
            }placeholder:{
                ProgressView()
            }
            .padding()
            Spacer()
        }
        .navigationTitle("Image Details")
    }
}
