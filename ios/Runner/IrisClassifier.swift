import Foundation
import CoreML
import Vision

@objc class CoreMLHandler: NSObject {
    
    @objc static let shared = CoreMLHandler()
    
    private var model: MLModel?
    private var visionModel: VNCoreMLModel?
    
    private override init() {
        super.init()
        setupModel()
    }
    
    private func setupModel() {
        do {
            if let modelURL = Bundle.main.url(forResource: "IrisClassifier", withExtension: "mlmodel") {
                model = try MLModel(contentsOf: modelURL)
                visionModel = try VNCoreMLModel(for: model!)
                print("CoreML model loaded successfully")
            } else {
                print("Model file not found")
            }
        } catch {
            print("Failed to load CoreML model: \(error)")
        }
    }
    
    @objc func predict(sepalLength: Double, sepalWidth: Double, petalLength: Double, petalWidth: Double, completion: @escaping (String?, Error?) -> Void) {
        guard let model = model else {
            completion(nil, NSError(domain: "CoreMLHandler", code: 1, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"]))
            return
        }
        
        let input: [String: Any] = [
            "sepal_length": sepalLength,
            "sepal_width": sepalWidth,
            "petal_length": petalLength,
            "petal_width": petalWidth
        ]
        
        do {
            let output = try model.prediction(from: MLDictionaryFeatureProvider(dictionary: input))
            
            guard let species = output.featureValue(for: "species")?.stringValue else {
                completion(nil, NSError(domain: "CoreMLHandler", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to extract prediction"]))
                return
            }
            
            completion(species, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    @objc func isUsingNeuralEngine() -> Bool {
        if #available(iOS 16.0, *) {
            return MLComputeUnits.cpuAndNeuralEngine.rawValue != 0
        }
        return false
    }
}