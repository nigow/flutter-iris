import Flutter
import UIKit

@objc public class FlutterCoreMLPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.flutter_coreml/coreml", binaryMessenger: registrar.messenger())
        let instance = FlutterCoreMLPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "predict":
            guard let args = call.arguments as? [String: Any],
                  let jsonInput = args["jsonInput"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            
            CoreMLHandler.shared.predict(jsonInput: jsonInput) { species, error in
                if let error = error {
                    result(FlutterError(code: "PREDICTION_FAILED", message: error.localizedDescription, details: nil))
                } else {
                    result(species)
                }
            }
            
        case "isUsingNeuralEngine":
            let isUsingNE = CoreMLHandler.shared.isUsingNeuralEngine()
            result(isUsingNE)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}