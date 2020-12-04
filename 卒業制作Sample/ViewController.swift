//
//  ViewController.swift
//  卒業制作Sample
//
//  Created by cmStudent on 2020/10/15.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var myTextView: UITextView!
    
    var imagePicker : UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        myTextView.text = ""
    }
    @IBAction func tapButton(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        
        imagePicker.dismiss(animated:true,completion:nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        myImageView.image = image
        
        predict(inputImage: image)
    }
    func predict(inputImage:UIImage){
        self.myTextView.text = " "
        
        guard let model=try? VNCoreMLModel(for: Sample().model) else {
            return
        }
        let request = VNCoreMLRequest(model: model){
            request,error in
            guard let results = request.results as? [VNClassificationObservation]else{
                return
            }
            DispatchQueue.main.async {
                for result in results{
                    let per = Int(result.confidence * 100)
                    if per >= 1{
                        let name = result.identifier
                        self.myTextView.text.append("これは、\(name)です。確率は\(per)% \n")
                    }
                }
            }
        }
        guard let ciImage = CIImage(image: inputImage) else {
            return
        }
        let imageHandler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do{
                try imageHandler.perform(([request]))
            }catch{
                print("エラー \(error)")
            }
        }
    }
}
