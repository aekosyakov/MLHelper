//
//  ViewController.swift
//  MLProject
//
//  Created by Alex Kosyakov on 29.07.2017.
//  Copyright © 2017 Alex Kosyakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var mlHelper: MLHalper!
    var modelType: MLModelType = MLModelType.ResNet50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mlHelper = MLHalper()
        self.imageView.contentMode = .scaleAspectFill
        self.predict(image: self.imageView.image)
    }
    
    override func viewDidLayoutSubviews() {
        self.imageHeightConstraint.constant = self.view.bounds.size.width
    }
}


// MARK: - IBActions
extension ViewController {
    
    @IBAction func pickImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
    }
    
    @IBAction func changeModelType(segmentedControl: UISegmentedControl) {
        let index = segmentedControl.selectedSegmentIndex
        self.modelType = MLModelType(rawValue:index)!
        
        self.predict(image: self.imageView.image)
    }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }

        self.predict(image: image)
    }
    
}

extension ViewController {
    func predict(image: UIImage?) {
        
        guard let img = image else {
            return
        }
        
        DispatchQueue.main.async {
            self.imageView.image = image;
            self.answerLabel.text = "start detecting"
        }
        
        self.mlHelper.predictImage(image: img,
                                   modelType: self.modelType,
                                   usingVision: true, completion: { results in
                                    DispatchQueue.main.async {
                                        self.answerLabel.text =  results.joined(separator: "\n")
                                       // self.answerLabel.text =
                                        print(results)
                                    }
        })
    }
}

