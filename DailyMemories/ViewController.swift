//
//  ViewController.swift
//  DailyMemories
//
//  Created by Meghan Kane on 9/3/17.
//  Copyright © 2017 Meghan Kane. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var expressionClassificationLabel: UILabel!
    @IBOutlet var sceneClassificationLabel: UILabel!
    @IBOutlet var captureMemoryButton: UIButton!
    var faceBoxView: UIView = UIView()
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureMemoryButton.layer.cornerRadius = 10
        imagePickerController.delegate = self
        expressionClassificationLabel.text = "how are you today? 🤔"
        sceneClassificationLabel.text = "where are you today? 🏖"
    }
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            imagePickerController.cameraDevice = .front
        }
        
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func classifySceneAndDetectFace(from image: UIImage) {
        // Create Vision Core ML request with model
        let model = GoogLeNetPlaces()
        guard let visionCoreMLModel = try? VNCoreMLModel(for: model.model) else { return }
        let sceneClassificationRequest = VNCoreMLRequest(model: visionCoreMLModel,
                                                         completionHandler: self.handleSceneClassificationResults)
        
        // Create Vision face detection request
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaceDetectionResults)
        
        // Create request handler
        guard let cgImage = image.cgImage else {
            fatalError("Unable to convert \(image) to CGImage.")
        }
        let cgImageOrientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgImageOrientation)
        
        // Perform both requests on handler
        self.sceneClassificationLabel.text = "Classifying scene..."
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([sceneClassificationRequest, faceDetectionRequest])
            } catch {
                print("Error performing scene classification")
            }
        }
    }
    
    // Do something with scene classification results
    private func handleSceneClassificationResults(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let classifications = request.results as? [VNClassificationObservation],
                let topClassification = classifications.first else {
                    self.sceneClassificationLabel.text = "Unable to classify scene.\n\(error!.localizedDescription)"
                    return
            }
            
            self.sceneClassificationLabel.text = "@ \(topClassification.identifier)"
        }
    }
    
    // Do something with face detection results
    private func handleFaceDetectionResults(request: VNRequest, error: Error?) {
        guard let observation = request.results?.first as? VNFaceObservation else {
            return
        }
  
        let updatedFaceBoxViewFrame = self.calculateFaceBoxViewFrame(faceBoundingBox: observation.boundingBox)
        DispatchQueue.main.async {
            self.addFaceBoxView(frame: updatedFaceBoxViewFrame)
        }
        
        // CLASSIFICATION kicks off here 🚀
        if let croppedFaceCGImage = self.imageView.image?.cgImage?.cropping(to: updatedFaceBoxViewFrame) {
            if let imageOrientation = self.imageView.image?.imageOrientation,
            let cgImageOrientation = CGImagePropertyOrientation(rawValue: UInt32(imageOrientation.rawValue)) {
                self.classifyFacialExpression(cgImage: croppedFaceCGImage, cgImageOrientation: cgImageOrientation)
            }
        }
    }
    
    func classifyFacialExpression(cgImage: CGImage, cgImageOrientation: CGImagePropertyOrientation) {
        // Create Vision Core ML request with model
        let model = EmotiClassifier()
        guard let visionCoreMLModel = try? VNCoreMLModel(for: model.model) else { return }
        let expressionClassificationRequest = VNCoreMLRequest(model: visionCoreMLModel,
                                                         completionHandler: self.handleExpressionClassificationResults)
        
        // Create request handler
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgImageOrientation)
        
        // Perform request on handler
        DispatchQueue.main.async {
            self.expressionClassificationLabel.text = "Classifying expression..."
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([expressionClassificationRequest])
            } catch {
                print("Error performing scene classification")
            }
        }
    }
    
    // Do something with expression classification results
    private func handleExpressionClassificationResults(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let classifications = request.results as? [VNClassificationObservation],
                let topClassification = classifications.first else {
                    self.expressionClassificationLabel.text = "Unable to classify expression.\n\(error!.localizedDescription)"
                    return
            }
            
            self.expressionClassificationLabel.text = topClassification.identifier
        }
    }
    
    // MARK: Helper methods
    
    private func convertToCGImageOrientation(from uiImage: UIImage) -> CGImagePropertyOrientation {
        let cgImageOrientation = CGImagePropertyOrientation(rawValue: UInt32(uiImage.imageOrientation.rawValue))!
        return cgImageOrientation
    }
    
    private func calculateFaceBoxViewFrame(faceBoundingBox: CGRect) -> CGRect {
        let boxViewFrame = transformRectInView(visionRect: faceBoundingBox, view: self.imageView)
        return boxViewFrame
    }
    
    private func addFaceBoxView(frame: CGRect) {
        self.faceBoxView.removeFromSuperview()
        
        let faceBoxView = UIView()
        styleFaceBoxView(faceBoxView)
        
        faceBoxView.frame = frame
        
        imageView.addSubview(faceBoxView)
        self.faceBoxView = faceBoxView
    }
    
    private func styleFaceBoxView(_ faceBoxView: UIView) {
        faceBoxView.layer.borderColor = UIColor.yellow.cgColor
        faceBoxView.layer.borderWidth = 2
        faceBoxView.backgroundColor = UIColor.clear
    }
    
    private func transformRectInView(visionRect: CGRect , view: UIView) -> CGRect {
        
        let size = CGSize(width: visionRect.width * view.bounds.width,
                          height: visionRect.height * view.bounds.height)
        let origin = CGPoint(x: visionRect.minX * view.bounds.width,
                             y: (1 - visionRect.minY) * view.bounds.height - size.height)
        return CGRect(origin: origin, size: size)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageSelected = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = imageSelected
            
            
            // Kick off Core ML task with image as input
            classifySceneAndDetectFace(from: imageSelected)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

