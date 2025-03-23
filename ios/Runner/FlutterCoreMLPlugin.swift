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
                  let jsonInput = args["jsonInput"] as? String,
                  let data = jsonInput.data(using: .utf8),
                  let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let sepalLength = jsonDict["sepal_length"] as? Double,
                  let sepalWidth = jsonDict["sepal_width"] as? Double,
                  let petalLength = jsonDict["petal_length"] as? Double,
                  let petalWidth = jsonDict["petal_width"] as? Double else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid JSON input format", details: nil))
                return
            }
            
            CoreMLHandler.shared.predict(
                sepalLength: sepalLength,
                sepalWidth: sepalWidth,
                petalLength: petalLength,
                petalWidth: petalWidth
            ) { species, error in
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
