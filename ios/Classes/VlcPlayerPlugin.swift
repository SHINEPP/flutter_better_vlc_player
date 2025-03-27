import Foundation
import Flutter

public class VlcPlayerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = VLCViewFactory(registrar: registrar)
        registrar.register(factory, withId: "flutter_video_plugin/getVideoView")
    }
    
    public func detachFromEngine(for registrar: any FlutterPluginRegistrar) {
        
    }
}
