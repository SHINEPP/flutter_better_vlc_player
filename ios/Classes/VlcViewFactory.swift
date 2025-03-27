import Foundation
import Flutter

public class VLCViewFactory: NSObject, FlutterPlatformViewFactory {
        
    private var registrar: FlutterPluginRegistrar
    private var playerCreator: VlcPlayerCreator

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        self.playerCreator = VlcPlayerCreator(registrar: registrar)
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let arguments = args as? NSDictionary ?? [:]
        let rViewId = (arguments["viewId"] as? NSNumber)?.int64Value ?? -1;
        return playerCreator.retPlayer(viewId: rViewId)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    public func detachFromEngine(for registrar: any FlutterPluginRegistrar) {
        playerCreator.disposePlayers()
    }
}
