import AVFoundation

class AudioPlayerViewModel: ObservableObject{
    @Published var isPlaying: Bool = false
    private var player: AVPlayer?
    func play(url: URL){
        player?.pause()
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
    }
    func pause(){
        player?.pause()
        isPlaying = false
    }
    
}

