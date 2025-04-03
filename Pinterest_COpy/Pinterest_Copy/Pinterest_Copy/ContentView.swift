import Foundation
import SwiftUI

struct ContentView: View{
    @StateObject private var viewModel = ImageViewModel()
    let colums=[
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    var body:some View{
        NavigationView{
            VStack{
                ScrollView{
                    LazyVGrid(columns:colums, spacing:10){
                        ForEach(viewModel.images.indices,id: \.self){ index in
                            let image=viewModel.images[index]
                            NavigationLink(destination: DetailedView(image:image)){
                                AsyncImage(url: URL(string: image.url)){ image in
                                    image.resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                }placeholder:{
                                    ProgressView()
                                }
                            }
                            .onAppear{
                                if index==viewModel.images.count-1{
                                    viewModel.fetchImage()
                                }
                                    
                            }
                        }
                    }
                    .padding()
                }
                Button("Load MOre Image"){
                    viewModel.fetchImage()
                }
                .padding()
            }
            .navigationTitle("Pinterest Gallery")
        }
    }
}
