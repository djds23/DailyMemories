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
    
    private func classifyScene(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            fatalError("Unable to convert \(image) to CGImage.")
        }
        let imageOrientation = UInt32(image.imageOrientation.rawValue)
        let cgImageOrientation = CGImagePropertyOrientation(rawValue: imageOrientation)!
        
        
        captionLabel.text = "Classifying scene..."
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgImageOrientation)
            do {
                try handler.perform([self.sceneClassificationRequest])
            } catch {
                print("Error performing classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    /* 1. Ask - create Vision + Core ML request, VNCoreMLRequest
     - Create VNCoreMLModel with EmotiClassifier
     - Create VNCoreMLRequest with:
     (1) the VNCoreMLModel that was just created
     (2) completion handler, handleClassificationResults
     - Set request's imageCropAndScaleOption to scaleFit since the model expects to see full face
     - Return request
     */
    lazy var sceneClassificationRequest: VNCoreMLRequest = {
        do {
            let sceneClassificationMLModel = GoogLeNetPlaces()
            
            let sceneClassificationVisionModel = try VNCoreMLModel(for: sceneClassificationMLModel.model)
            let request = VNCoreMLRequest(model: sceneClassificationVisionModel,
                                          completionHandler: self.handleClassificationResults)
            request.imageCropAndScaleOption = .scaleFit
            return request
            
        } catch {
            fatalError("Error loading Vision ML model: \(error)")
        }
    }()
    
    /* 3. Results - do something with Vision's results (classifications)
     - Check to see if there are any VNClassificationObservation results on the requests. Update user if not.
     - Call updateClassificationLabel with the top 2 classifications
     Show any other updates to the user that you'd like 💅🏽
     Make sure UI updates are dispatched on the main queue
     */
    func handleClassificationResults(for request: VNRequest, error: Error?) {
        
        DispatchQueue.main.async {
            guard let classifications = request.results as? [VNClassificationObservation],
                classifications.isEmpty != true else {
                    self.captionLabel.text = "Unable to classify facial expression.\n\(error!.localizedDescription)"
                    return
            }
            self.updateCaptionLabel(classifications)
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
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageSelected = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            // Kick off Core ML task with image as input
            classifyScene(from: imageSelected)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
