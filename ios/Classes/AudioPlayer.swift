import Foundation

import AVKit


//https://stackoverflow.com/questions/36865233/get-avaudioplayer-to-play-multiple-sounds-at-a-time
class AudioPlayer : NSObject, AVAudioPlayerDelegate {
    
    private var seekToStart = true
    private var timer : Timer?
    private var audioPlayers: [String:AVAudioPlayer] = [:]
    var plugin : SwiftAudioWaveformsPlugin
    
    init(plugin : SwiftAudioWaveformsPlugin){
        self.plugin = plugin
    }
    
    
    func preparePlayer(path: String?,volume: Double?,key: String?,result:  @escaping FlutterResult){
        if(key != nil){
            let playerExists = audioPlayers[key!] != nil
            if(!(path ?? "").isEmpty){
                let audioUrl = URL.init(fileURLWithPath: path!)
                if(playerExists){
                    result(true)
                }else{
                    let player = try! AVAudioPlayer(contentsOf: audioUrl)
                    audioPlayers.updateValue(player, forKey: key!)
                    player.prepareToPlay()
                    player.volume = Float(volume ?? 1.0)
                    result(true)
                }
            }else {
                result(FlutterError(code: "", message: "Audio file path can't be empty or null", details: nil))
            }
        }else {
            result(false)
        }
        
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                              successfully flag: Bool){
        player.currentTime = player.duration
    }
    
    func startPlyer(key: String?,result:  @escaping FlutterResult){
        if(key != nil){
            audioPlayers[key!]?.play()
            audioPlayers[key!]?.delegate = self
            startListening(key: key!)
            result(true)
        }
        else {
            result(false)
        }
    }
    
    func pausePlayer(key: String?,result:  @escaping FlutterResult){
        if(key != nil){
            stopListening()
            audioPlayers[key!]?.pause()
            result(true)
        }
        else {
            result(false)
        }
    }
    
    func stopPlayer(key: String?,result:  @escaping FlutterResult){
        if(key != nil){
            stopListening()
            audioPlayers[key!]?.stop()
            result(true)
        }
        else {
            result(false)
        }
    }
    
    //TODO:
    @objc func playerDidFinishPlaying(playerItem: AVPlayerItem){
        if(seekToStart){
        }
        
    }
    
    func getDuration(key: String?,_ type:DurationType,_ result:  @escaping FlutterResult) throws {
        if(key != nil){
            if type == .Current {
                let ms = (audioPlayers[key!]?.currentTime ?? 0) * 1000
                result(Int(ms))
            }else{
                let ms = (audioPlayers[key!]?.duration ?? 0) * 1000
                result(Int(ms))
            }
        }else{
            result(false)
        }
        
    }
    
    func setVolume(key: String?,_ volume: Double?,_ result : @escaping FlutterResult) {
        if(key != nil){
            audioPlayers[key!]?.volume = Float(volume ?? 1.0)
            result(true)
        }
        else{
            result(false)
        }
    }
    
    func seekTo(key: String?,_ time: Int?,_ result : @escaping FlutterResult) {
        if(key != nil){
            audioPlayers[key!]?.currentTime = Double(time!/1000)
            result(true)
        }else{
            result(false)
        }
        
    }
    
    func startListening(key: String){
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: {_ in
            let ms = (self.audioPlayers[key]?.currentTime ?? 0) * 1000
            self.plugin.onCurrentDuration(duration: Int(ms),key: key)
        })
    }
    
    func stopListening(){
        timer?.invalidate()
    }
}
