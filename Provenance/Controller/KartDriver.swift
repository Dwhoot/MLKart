//
//  KartDriver.swift
//  KartTest
//
//  Created by William McGinty on 6/22/18.
//  Copyright © 2018 William McGinty. All rights reserved.
//

import UIKit
import CoreML
import Vision

class KartDriver {
    
    enum Control: String {
        case accelerate = "A"
        case accelerateLeft = "L-A"
        case accelerateRight = "R-A"
        
        init?(rawValue: String) {
            if rawValue == Control.accelerate.rawValue {
                self = .accelerate
            } else if rawValue == Control.accelerateLeft.rawValue {
                self = .accelerateLeft
            } else if rawValue == Control.accelerateRight.rawValue {
                self = .accelerateRight
            } else {
                return nil
            }
        }
    }
    
    private var request: VNCoreMLRequest?
    private var completion: ((Control?) -> Void)?
    
    init(model: MLModel) throws {
        request = VNCoreMLRequest(model: try VNCoreMLModel(for: model)) { [weak self] request, error in
            let control = KartDriver.handle(request: request, error: error)
            self?.completion?(control)
        }
    }
    
    func predict(image: UIImage, completion: @escaping (Control?) -> Void) {
        self.completion = completion
        guard let cgImage = image.cgImage, let request = request else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        try? handler.perform([request])
    }
    
    // MARK: Handler
    static func handle(request: VNRequest, error: Error?) -> Control? {
        if let results = request.results as? [VNClassificationObservation], let predicted = results.first, let prediction = Control(rawValue: predicted.identifier) {
            return prediction
        }
        
        return nil
    }
}
