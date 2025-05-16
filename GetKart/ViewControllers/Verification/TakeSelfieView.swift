//
//  TakeSelfieView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/04/25.
//

import SwiftUI

struct TakeSelfieView: View {
    
    @State private var showCapturedImage = false
    @State private var capturedImage: UIImage?
    var navigation:UINavigationController?
   // @State private var coordinator: CameraView.CameraCoordinator?
    var businessName:String?

    var body: some View {
        
        // Top Navigation Bar
        HStack {
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                    .padding()
            }
            Spacer()
        }.frame(height: 44)
        
        VStack(spacing: 20) {
          //  VStack(){
                
                // Title with Progress Indicator
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Take a Selfie")
                            .font(.manrope(.bold, size: 18))
                        
                        Spacer()
                        Text("Step 3 of 3")
                            .foregroundColor(.gray)
                    }
                    
                    // Progress Bar
                    ProgressView(value: 0.7)
                        .progressViewStyle(LinearProgressViewStyle(tint: .black))
                    
                    
                    Text("Ensure your face is clear and visible")
                        .font(.subheadline)
                }.padding(.top,15)
                .padding(.horizontal, 20)
          //  Spacer()
            HStack{
                Text("Click a clear selfie").font(.manrope(.regular, size: 14)).frame(alignment: .leading)
                Spacer()
            }.padding(.horizontal)
         
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                
                    .scaledToFit()
                    .frame(height: 420)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .frame(width: widthScreen-40)
              //  Spacer()
                HStack {
                    Button("Re-take") {
                        capturedImage = nil
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .foregroundColor(.orange)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 1)
                    }
                    
                    Button("Next") {
                        // Navigate to next screen
                        var swidtUIView = TakeFrontDocumentView(navigation:navigation)
                        swidtUIView.businessName = businessName
                        swidtUIView.capturedSelfieImage = capturedImage
                        let hostVC = UIHostingController(rootView: swidtUIView)
                        self.navigation?.pushViewController(hostVC, animated: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    //.padding(.horizontal)
                }
                .padding()
                
            } else {
                ZStack {
                
                    CameraView(capturedImage: $capturedImage, onImageCaptured: {
                        
                    }, isFrontCamera: true, cameraHeight: 420)
                    .frame(height: 420)
                    .cornerRadius(12)
                   
                    VStack{
                        Spacer()
                        Text("Look at the camera and smile!")
                            .font(.manrope(.regular, size: 14))
                            .foregroundColor(.white)
                            .frame(minHeight:35)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#FFB546").opacity(0.8))
                            .cornerRadius(12, corners: [.bottomLeft,.bottomRight])
                    }
                 
                }.frame(height: 420).padding(.horizontal)

              //  Spacer()
                
                Button("Capture") {
                    // Trigger photo capture and set capturedImage
                    
                    //coordinator?.capturePhoto()
                    NotificationCenter.default.post(name: .init("capturePhoto"), object: nil)
                 

                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom,10)
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color(UIColor.systemGray6))
    }
}

#Preview {
    TakeSelfieView()
}




import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    var onImageCaptured: () -> Void
    var isFrontCamera = true
    var cameraHeight:CGFloat
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.cameraHeight = cameraHeight
        controller.isFrontCamera = isFrontCamera
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> CameraCoordinator {
        CameraCoordinator(parent: self)
    }

    class CameraCoordinator: NSObject, AVCapturePhotoCaptureDelegate {
        let parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func capturePhoto() {
            parentController?.capturePhoto()
        }

        func photoOutput(_ output: AVCapturePhotoOutput,
                         didFinishProcessingPhoto photo: AVCapturePhoto,
                         error: Error?) {
            if let data = photo.fileDataRepresentation(),
               let image = UIImage(data: data) {
                parent.capturedImage = image
                parent.onImageCaptured()
            }
        }

        weak var parentController: CameraViewController?
    }
}

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: CameraView.CameraCoordinator?
    var isFrontCamera = true
    var cameraHeight = 0.0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        NotificationCenter.default.addObserver(self, selector: #selector(capturePhoto), name: .init("capturePhoto"), object: nil)
        self.navigationController?.navigationBar.isHidden = true
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: (isFrontCamera) ? .front : .back),
              let input = try? AVCaptureDeviceInput(device: frontCamera) else { return }
        
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = view.bounds
//        view.layer.addSublayer(previewLayer)
                
        previewLayer.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: cameraHeight)
        
        view.layer.insertSublayer(previewLayer, at: 0)
        
        delegate?.parentController = self
        captureSession.startRunning()
    }

    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: delegate!)
    }
}
