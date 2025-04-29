import Foundation
import FlutterMacOS

public class VlcPlayerPlugin: NSObject, FlutterPlugin {
        
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_video_plugin_channel", binaryMessenger: registrar.messenger)
        
        let plugin = VlcPlayerPlugin(registrar: registrar)
        //registrar.addMethodCallDelegate(plugin, channel: channel)
        
        let factory = VlcPlayerViewFactory(registrar: registrar, playerCreator: plugin.playerCreator)
        registrar.register(factory, withId: "flutter_video_plugin/getVideoView")
    }
    
    // VlcPlayerPlugin instance
    private var playerCreator: VlcPlayerController
    
    init(registrar: FlutterPluginRegistrar) {
        self.playerCreator = VlcPlayerController(registrar: registrar)
        super.init()
    }
    
    public func detachFromEngine(for registrar: any FlutterPluginRegistrar) {
        self.playerCreator.detachFromEngine()
    }
}
