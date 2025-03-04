import Foundation
import CoreML
import Vision

@objc class CoreMLHandler: NSObject {
    
    @objc static let shared = CoreMLHandler()
    
    private var model: MLModel?
    
    private override init() {
        super.init()
        setupModel()
    }
    
    private func setupModel() {
        let modelURL = Bundle.main.url(forResource: "IrisClassifier", withExtension: "mlmodelc") ??
                      Bundle(for: type(of: self)).url(forResource: "IrisClassifier", withExtension: "mlmodel")
        
        if let modelURL = modelURL {
            print("Found model URL: \(modelURL)")
            do {
                model = try MLModel(contentsOf: modelURL)
                print("CoreML model loaded successfully")
            } catch {
                print("Failed to load CoreML model: \(error)")
            }
        } else {
            print("Model file not found")
        }
    }
    
    @objc func predict(sepalLength: Double, sepalWidth: Double, petalLength: Double, petalWidth: Double, completion: @escaping (String?, Error?) -> Void) {
        guard let model = model else {
            completion(nil, NSError(domain: "CoreMLHandler", code: 1, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"]))
            return
        }
        
        do {
            let inputArray = try MLMultiArray(shape: [4], dataType: .double)
            inputArray[0] = NSNumber(value: sepalLength)
            inputArray[1] = NSNumber(value: sepalWidth)
            inputArray[2] = NSNumber(value: petalLength)
            inputArray[3] = NSNumber(value: petalWidth)
            
            let provider = try MLDictionaryFeatureProvider(dictionary: ["input": inputArray])
            
            let output = try model.prediction(from: provider)
            
            guard let speciesIndex = output.featureValue(for: "species")?.int64Value else {
                completion(nil, NSError(domain: "CoreMLHandler", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to extract prediction"]))
                return
            }

            let speciesList: [String] = ["setosa", "versicolor", "virginica"]
            
            completion(speciesList[Int(speciesIndex)], nil)
        } catch {
            print("Prediction error: \(error.localizedDescription)")
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
