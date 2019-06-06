//
//  CameraViewController.swift
//  SwiftStitch
//
//  Created by dev_laibin on 2019/6/6.
//  Copyright © 2019 ellipsis.com. All rights reserved.
//

import UIKit
import AVFoundation
@available(iOS 10.0, *)
class CameraViewController: UIViewController ,AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
       let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
//        do {
//            let input = try AVCaptureDeviceInput(device: backCamera!)
//
//            stillImageOutput = AVCapturePhotoOutput()
//            
//            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
//                captureSession.addInput(input)
//                captureSession.addOutput(stillImageOutput)
//                setupLivePreview()
//            }
//        }
//        catch let error  {
//            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
//        }
        
        
    }
    @IBOutlet weak var previewView: UIView!
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        //Step12
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    var imageArray:[UIImage?] = Array()
    @IBAction func didTakePhoto(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
     
        
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
//        captureImageView.image = image
        self.imageArray.append(image)
        if self.imageArray.count < 2 {
            testBtn.setTitle("over", for: .normal)
            return
        }
        testBtn.setTitle("ing", for: .normal)
        DispatchQueue.global().async {
            let stitchedImage:UIImage = CVWrapper.process(with: self.imageArray as! [UIImage]) as UIImage
            DispatchQueue.main.async {
                if stitchedImage == nil {
                    NSLog("stichedImage %@=====%d", stitchedImage,self.imageArray.count)
                    self.imageArray.remove(at: self.imageArray.count-1)
                }else{
                    NSLog("stichedImage %@=====%d", stitchedImage,self.imageArray.count)
                    self.captureImageView.image = stitchedImage
                }
               self.testBtn.setTitle("ok", for: .normal)
            }
            if let data = stitchedImage.pngData() {
                let filename = self.getDocumentsDirectory().appendingPathComponent("copy.png")
                try? data.write(to: filename)
                
            }
        }
        
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
 
    @IBOutlet weak var testBtn: UIButton!
    @IBAction func backAction(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        let imag = CVWrapper.test();
        self.captureImageView.image = imag;
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBOutlet weak var captureImageView: UIImageView!
}
