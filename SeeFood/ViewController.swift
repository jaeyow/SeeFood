//
//  ViewController.swift
//  SeeFood
//
//  Created by Lorence Lim on 28/01/2018.
//  Copyright © 2018 Lorence Lim. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            
            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("Could not convert UIImage to CIImage.")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        // load model using Inceptionv3 model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed.")
        }
        
        // request to classify the data
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            if let firstResult = results.first {
                guard let navBar = self.navigationController?.navigationBar else { fatalError() }
                let whiteColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha:1.0)
                
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    navBar.barTintColor = UIColor(red: 0.15, green: 0.65, blue: 0.36, alpha: 1.0)
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                    navBar.barTintColor = UIColor(red: 0.84, green: 0.27, blue: 0.25, alpha: 1.0)
                }
                navBar.tintColor = whiteColor
                navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: whiteColor]
            }
        }
        
        // perform classifying of image
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

