import Foundation
import Flutter

public class VlcPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
        
    private var playerController: VlcPlayerController

    init(registrar: FlutterPluginRegistrar, playerCreator: VlcPlayerController) {
        self.playerController = playerCreator
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let arguments = args as? NSDictionary ?? [:]
        let rViewId = (arguments["viewId"] as? NSNumber)?.int64Value ?? -1;
        let player = playerController.pickPlayer(viewId: rViewId)
        return player
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
