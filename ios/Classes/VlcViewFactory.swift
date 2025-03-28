import Foundation
import Flutter

public class VLCViewFactory: NSObject, FlutterPlatformViewFactory {
        
    private var playerCreator: VlcPlayerCreator

    init(registrar: FlutterPluginRegistrar, playerCreator: VlcPlayerCreator) {
        self.playerCreator = playerCreator
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let arguments = args as? NSDictionary ?? [:]
        let rViewId = (arguments["viewId"] as? NSNumber)?.int64Value ?? -1;
        let player = playerCreator.retPlayer(viewId: rViewId)
        player.reHostedView(frame: frame)
        return player
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
