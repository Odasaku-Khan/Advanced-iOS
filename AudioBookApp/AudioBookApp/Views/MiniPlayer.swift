import SwiftUI
struct MiniPlayer:View{
    @ObservedObject var viewModel:AudioPlayerViewModel
    
    var body: some View{
        HStack{
            Button(action: {
                viewModel.isPlaying ? viewModel.pause(): viewModel.play(url: "./audio.mp3")
            }){
                Image(systemName: viewModel.isPlaying ? "pause.fill":"play.fill")
            }
            Text("Now playing: \(viewModel.currentBook ?? "No book")
        }
        .padding(.horizontal)
    }
}
