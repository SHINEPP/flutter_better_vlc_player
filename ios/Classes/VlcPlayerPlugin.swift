import Foundation
import Flutter

public class VlcPlayerPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_video_plugin_channel", binaryMessenger: registrar.messenger())
        
        let plugin = VlcPlayerPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(plugin, channel: channel)
        
        let factory = VLCViewFactory(registrar: registrar, playerCreator: plugin.playerCreator)
        registrar.register(factory, withId: "flutter_video_plugin/getVideoView")
    }
    
    private var playerCreator: VlcPlayerCreator
    
    init(registrar: FlutterPluginRegistrar) {
        self.playerCreator = VlcPlayerCreator(registrar: registrar)
        super.init()
    }
    
    public func detachFromEngine(for registrar: any FlutterPluginRegistrar) {
        self.playerCreator.disposePlayers()
    }
}
