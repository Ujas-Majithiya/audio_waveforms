import Flutter
import UIKit

public class SwiftAudioWaveformsPlugin: NSObject, FlutterPlugin {
    
    final var audioRecorder = AudioRecorder()
    var audioPlayer : AudioPlayer?
    var flutterChannel: FlutterMethodChannel
    
    init(registrar: FlutterPluginRegistrar, flutterChannel: FlutterMethodChannel) {
        self.flutterChannel = flutterChannel
        super.init()
        self.audioPlayer = AudioPlayer(plugin: self)
    }
    struct Constants {
        static let methodChannelName = "simform_audio_waveforms_plugin/methods"
        static let startRecording = "startRecording"
        static let pauseRecording = "pauseRecording"
        static let stopRecording = "stopRecording"
        static let getDecibel = "getDecibel"
        static let checkPermission = "checkPermission"
        static let path = "path"
        static let encoder = "encoder"
        static let sampleRate = "sampleRate"
        static let fileNameFormat = "YY-MM-dd-HH-mm-ss"
        static let readAudioFile = "readAudioFile"
        static let durationEventChannel = "durationEventChannel"
        static let startPlayer = "startPlayer"
        static let stopPlayer = "stopPlayer"
        static let pausePlayer = "pausePlayer"
        static let seekTo = "seekTo"
        static let progress = "progress"
        static let setVolume = "setVolume"
        static let volume = "volume"
        static let getDuration = "getDuration"
        static let durationType = "durationType"
        static let preparePlayer = "preparePlayer"
        static let seekToStart = "seekToStart"
        static let onCurrentDuration = "onCurrentDuration"
        static let current = "current"
        static let playerKey = "playerKey"
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Constants.methodChannelName, binaryMessenger: registrar.messenger())
        let instance = SwiftAudioWaveformsPlugin(registrar: registrar, flutterChannel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        switch call.method {
        case Constants.startRecording:
            audioRecorder.startRecording(result,  args?[Constants.path] as? String,
                                         args?[Constants.encoder] as? Int, args?[Constants.sampleRate] as? Int,Constants.fileNameFormat)
            break
        case Constants.pauseRecording:
            audioRecorder.pauseRecording(result)
            break
        case Constants.stopRecording:
            audioRecorder.stopRecording(result)
            break
        case Constants.getDecibel:
            audioRecorder.getDecibel(result)
            break
        case Constants.checkPermission:
            audioRecorder.checkHasPermission(result)
            break
        case Constants.preparePlayer:
            let key = args?[Constants.playerKey] as? String
            
            audioPlayer?.preparePlayer(path: args?[Constants.path] as? String, volume: args?[Constants.volume] as? Double,key: key,result: result)
            break
        case Constants.startPlayer:
            let key = args?[Constants.playerKey] as? String
            audioPlayer?.startPlyer(key: key, result: result)
            break
        case Constants.pausePlayer:
            let key = args?[Constants.playerKey] as? String
            audioPlayer?.pausePlayer(key: key, result: result)
            break
        case Constants.stopPlayer:
            let key = args?[Constants.playerKey] as? String
            audioPlayer?.stopPlayer(key: key,result: result)
            break
        case Constants.seekTo:
            let key = args?[Constants.playerKey] as? String
            audioPlayer?.seekTo(key: key,args?[Constants.progress] as? Int,result)
        case Constants.setVolume:
            let key = args?[Constants.playerKey] as? String
            audioPlayer?.setVolume(key: key,args?[Constants.volume] as? Double,result)
        case Constants.getDuration:
            let type = args?[Constants.durationType] as? Int
            let key = args?[Constants.playerKey] as? String
            do{
                if(type == 0){
                    try audioPlayer?.getDuration(key: key,DurationType.Current,result)
                } else {
                    try audioPlayer?.getDuration(key: key, DurationType.Max,result)
                }
            } catch{
                result(FlutterError(code: "", message: "Failed to get duration", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    func onCurrentDuration(duration: Int,key: String){
        flutterChannel.invokeMethod(Constants.onCurrentDuration, arguments: [Constants.current : duration,Constants.playerKey: key])
    }
}
