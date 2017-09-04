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
    @IBOutlet var captionLabel: UILabel!
    var faceBoxView: UIView = UIView()
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 10
        imagePickerController.delegate = self
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
        let sceneClassificationRequest = VNCoreMLRequest(
          model: visionCoreMLModel,
          completionHandler: self.handleSceneClassificationResults
        )
        
        /* 1. Create Vision face detection request
           - completion handler should take in handleFaceDetectionResults */
      let faceDetectionRequest = VNDetectFaceRectanglesRequest(
        completionHandler: self.handleFaceDetectionResults
      )
        
        // Create request handler
        guard let cgImage = image.cgImage else {
            fatalError("Unable to convert \(image) to CGImage.")
        }
        let cgImageOrientation = CGImagePropertyOrientation(
          rawValue: UInt32(image.imageOrientation.rawValue)
          )!
        let handler = VNImageRequestHandler(
          cgImage: cgImage,
          orientation: cgImageOrientation
      )
      
      DispatchQueue.main.async {
          self.captionLabel.text = "Classifying scene, detecting face..."
      }
        
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          try handler.perform([sceneClassificationRequest, faceDetectionRequest])
        } catch {
          
          
        }
      }
    }
    
    // Do something with scene classification results
    private func handleSceneClassificationResults(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let classifications = request.results as? [VNClassificationObservation],
                classifications.isEmpty != true else {
                    self.captionLabel.text = "Unable to classify scene.\n\(error!.localizedDescription)"
                    return
            }
            self.updateCaptionLabel(classifications)
        }
    }
    
    /* 3. Do something with face detection results
       - Add face box view
       - Ensure that it is dispatched on the main queue, because we are updating the UI */
    private func handleFaceDetectionResults(request: VNRequest, error: Error?) {
        
      guard let observation = request.results?.first as? VNFaceObservation else {
        return
      }
      
      DispatchQueue.main.async {
        self.addFaceBoxView(faceBoundingBox: observation.boundingBox)
      }
        
    }
    
    // MARK: Helper methods
    
    private func updateCaptionLabel(_ classifications: [VNClassificationObservation]) {
        let topTwoClassifications = classifications.prefix(2)
        let descriptions = topTwoClassifications.map { classification in
            return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
        }
        self.captionLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
    }
    
    private func convertToCGImageOrientation(from uiImage: UIImage) -> CGImagePropertyOrientation {
        let cgImageOrientation = CGImagePropertyOrientation(rawValue: UInt32(uiImage.imageOrientation.rawValue))!
        return cgImageOrientation
    }
    
    private func addFaceBoxView(faceBoundingBox: CGRect) {
        let faceBoxView = UIView()
        
        let boxViewFrame = transformRectInView(visionRect: faceBoundingBox, view: self.imageView)
        faceBoxView.frame = boxViewFrame
        
        imageView.addSubview(faceBoxView)
        self.faceBoxView = faceBoxView
        styleFaceBoxView(faceBoxView)
    }
    
    private func styleFaceBoxView(_ faceBoxView: UIView) {
        faceBoxView.layer.borderColor = UIColor.yellow.cgColor
        faceBoxView.layer.borderWidth = 2
        faceBoxView.backgroundColor = UIColor.clear
    }
    
    private func transformRectInView(visionRect: CGRect , view: UIView) -> CGRect {
      
      let size = CGSize(
        width: visionRect.width * view.bounds.width,
        height: visionRect.height * view.bounds.height
      )
      let origin = CGPoint(
        x: visionRect.minX * view.bounds.width,
        y: (1 - visionRect.minY) * view.bounds.height - size.height
      )
      return CGRect(origin: origin, size: size)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageSelected = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = imageSelected
            self.faceBoxView.removeFromSuperview()
            
            
            // Kick off Core ML task with image as input
            classifySceneAndDetectFace(from: imageSelected)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

