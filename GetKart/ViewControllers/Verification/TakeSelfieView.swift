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
    @State private var coordinator: CameraView.CameraCoordinator?

    var body: some View {
        
        // Top Navigation Bar
        HStack {
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black).padding()
            }
            Spacer()
        }.frame(height: 44)
        
        VStack(spacing: 30) {
          //  VStack(){
                
                // Title with Progress Indicator
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Take a Selfie")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        Text("Step 3 of 3")
                            .foregroundColor(.gray)
                    }
                    
                    // Progress Bar
                    ProgressView(value: 0.5)
                        .progressViewStyle(LinearProgressViewStyle(tint: .black))
                    
                    
                    Text("Ensure your face is clear and visible")
                        .font(.subheadline)
                }.padding(.top,30)
                .padding(.horizontal, 20)
          
             
           // }
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(12)
                HStack {
                    Button("Re-take") {
                        capturedImage = nil
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Next") {
                        // Navigate to next screen
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                ZStack {
                    
                    CameraView(capturedImage: $capturedImage) {
                        
                        
                        
                    } .frame(height: 300)
                        .cornerRadius(12)
                    Text("Look at the camera and smile!")
                        .foregroundColor(.white)
                        .bold()
                        .padding(8)
                        .background(.orange.opacity(0.8))
                        .cornerRadius(8)
                       // .padding()
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .frame(width: .infinity)
                        .padding(.bottom,10)
                }.padding(.horizontal)

                Button("Capture") {
                    // Trigger photo capture and set capturedImage
                    
                    coordinator?.capturePhoto()

                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .background(Color(UIColor.systemGray6))
    }
}

#Preview {
    TakeSelfieView()
}



/*


import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video),
        let input = try? AVCaptureDeviceInput(device: backCamera) else { return }

        captureSession.addInput(input)
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
}

*/

/*




struct SelfieCaptureView: View {
    @State private var capturedImage: UIImage?
    @State private var navigate = false
    @State private var coordinator: CameraView.CameraCoordinator?

    var body: some View {
        NavigationView {
            VStack {
                Text("Take a Selfie")
                    .font(.title2.bold())
                    .padding(.top)

                if capturedImage == nil {
                    ZStack {
                        CameraView(capturedImage: $capturedImage) {
                            navigate = true
                        }
                        .frame(height: 400)
                        .cornerRadius(12)
                    }

                    Button("Capture") {
                        coordinator?.capturePhoto()
                    }
                    .padding()
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                } else {
                    Image(uiImage: capturedImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(12)

                    NavigationLink(destination: IDCaptureStepView(), isActive: $navigate) {
                        EmptyView()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
*/

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    var onImageCaptured: () -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .front),
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
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        delegate?.parentController = self
        captureSession.startRunning()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: delegate!)
    }
}
