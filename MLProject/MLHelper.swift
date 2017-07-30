//
//  MLHelper.swift
//  MLProject
//
//  Created by Alex Kosyakov on 29.07.2017.
//  Copyright © 2017 Alex Kosyakov. All rights reserved.
//

import UIKit
import CoreML
import Vision

typealias MLHelperResultsCompletion = ([String]) -> ()
typealias MLVisionResultsCompletion = ([VNClassificationObservation]?) -> ()

enum MLModelType: Int {
    case ResNet50 = 0, SqueezeNet, InceptionV3, GoogLeNetPlaces, Yolo, VGG16
}

class MLHalper {
    
    private var resNet50: Resnet50?
    private var squeezeNet: SqueezeNet?
    private var inceptionV3: Inceptionv3?
    private var googlePlaces: GoogLeNetPlaces?
    
    init() {
        self.resNet50     = Resnet50()
        self.squeezeNet   = SqueezeNet()
        self.inceptionV3  = Inceptionv3()
        self.googlePlaces = GoogLeNetPlaces()
    }
    
    func predictImage(image:UIImage,
                      modelType:MLModelType,
                      usingVision:Bool,
                      completion: MLHelperResultsCompletion?) {
        if (usingVision) {
            self.predictUsingVision(modelType: modelType, image: image, finishCompletion: { (results) in

                guard let items = results,
                      let handler     = completion
                else {
                    print("no results")
                    return
                }
 
                let words = items.prefix(upTo: 5).map {
                    $0.identifier + ":  \($0.confidence)"
                }

                
                handler(words)

            })
        }
        
    }
    
}

extension MLHalper {
    
    func predictUsingVision(modelType: MLModelType,
                            image:UIImage,
                            finishCompletion: MLVisionResultsCompletion?) {
        guard let ciImage = CIImage(image:image) else {
            fatalError("couldnt convert UIImage to CIImage")
        }
        
        var model = MLModel()
        
        switch modelType {
        case .ResNet50:
            print("res net")
            model = (self.resNet50?.model)!
        case .SqueezeNet:
            print("squeexe net")
            model = (self.squeezeNet?.model)!
        case .GoogLeNetPlaces:
            model = (self.googlePlaces?.model)!
        case .InceptionV3:
            model = (self.inceptionV3?.model)!
        default: print("default")
        }
        
        guard let visionModel = try? VNCoreMLModel(for: model) else {
            fatalError("can't load Places ML model")
        }
        
        let request = VNCoreMLRequest(model: visionModel) {request, error in
            guard let results = request.results as? [VNClassificationObservation], let handler = finishCompletion else {
                fatalError("unexpected result type from VNCoreMLRequest")
            }
            handler(results)
            
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}

