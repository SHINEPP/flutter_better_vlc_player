import Foundation
import FlutterMacOS

public class VlcPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
    
    private var playerController: VlcPlayerController

    init(registrar: FlutterPluginRegistrar, playerCreator: VlcPlayerController) {
        self.playerController = playerCreator
        super.init()
    }
    
    public func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
        let arguments = args as? NSDictionary ?? [:]
        let rViewId = (arguments["viewId"] as? NSNumber)?.int64Value ?? -1;
        let player = playerController.pickPlayer(viewId: rViewId)
        return player.view()
    }
}
