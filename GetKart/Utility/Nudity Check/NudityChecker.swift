//
//  NudityChecker.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/04/26.
//

import Foundation
import CoreML
import Vision

class NudityChecker{
    
   static func detectNudity(in image: UIImage, completion: @escaping (Bool, VNConfidence?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(false, nil)
            return
        }

        do {
            let configuration = MLModelConfiguration()
            let coreMLModel = try OpenNSFW(configuration: configuration).model
            let vnModel = try VNCoreMLModel(for: coreMLModel)

            let request = VNCoreMLRequest(model: vnModel) { request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    completion(false, nil)
                    return
                }

                let explicitKeywords = ["nsfw", "nudity", "porn", "sexual", "explicit"]
                var maxConfidence: VNConfidence = 0.0
                var isExplicit = false

                for result in results {
                    let label = result.identifier.lowercased()
                    if explicitKeywords.contains(where: { label.contains($0) }) {
                        isExplicit = true
                        maxConfidence = max(maxConfidence, result.confidence)
                    }
                }

                completion(isExplicit, maxConfidence)
            }

            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Failed to perform VN request: \(error)")
                    completion(false, nil)
                }
            }

        } catch {
            print("Failed to load Core ML model: \(error)")
            completion(false, nil)
        }
    }

    
}
