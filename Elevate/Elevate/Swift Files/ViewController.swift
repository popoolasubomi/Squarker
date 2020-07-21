/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The implementation of the application's view controller, responsible for coordinating
 the user interface, video feed, and PoseNet model.
*/

import AVFoundation
import UIKit
import VideoToolbox

class ViewController: UIViewController {
    /// The view the controller uses to visualize the detected poses.
    @IBOutlet private var previewImageView: PoseImageView!
   
    @IBOutlet weak var labelgudei: UILabel!
    
    var counter = 0
    var previous = [Float]()
    var current = [Float]()
    var oken: String = "r"
    
    private let videoCapture = VideoCapture()

    private var poseNet: PoseNet!

    /// The frame the PoseNet model is currently making pose predictions from.
    private var currentFrame: CGImage?

    /// The algorithm the controller uses to extract poses from the current frame.
    private var algorithm: Algorithm = .multiple

    /// The set of parameters passed to the pose builder when detecting poses.
    private var poseBuilderConfiguration = PoseBuilderConfiguration()

    private var popOverPresentationManager: PopOverPresentationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        // For convenience, the idle timer is disabled to prevent the screen from locking.
        UIApplication.shared.isIdleTimerDisabled = true

        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }

    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.delegate = self

            self.videoCapture.startCapturing()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Reinitilize the camera to update its output stream with the new orientation.
        setupAndBeginCapturingVideoFrames()
    }

    @IBAction func onCameraButtonTapped(_ sender: Any) {
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }

    @IBAction func onAlgorithmSegmentValueChanged(_ sender: UISegmentedControl) {
        guard let selectedAlgorithm = Algorithm(
            rawValue: sender.selectedSegmentIndex) else {
                return
        }

        algorithm = selectedAlgorithm
    }
}

// MARK: - Navigation

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let uiNavigationController = segue.destination as? UINavigationController else {
            return
        }
        guard let configurationViewController = uiNavigationController.viewControllers.first
            as? ConfigurationViewController else {
                    return
        }

        configurationViewController.configuration = poseBuilderConfiguration
        configurationViewController.algorithm = algorithm
        configurationViewController.delegate = self

        popOverPresentationManager = PopOverPresentationManager(presenting: self,
                                                                presented: uiNavigationController)
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = popOverPresentationManager
    }
}

// MARK: - ConfigurationViewControllerDelegate

extension ViewController: ConfigurationViewControllerDelegate {
    func configurationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateConfiguration configuration: PoseBuilderConfiguration) {
        poseBuilderConfiguration = configuration
    }

    func configurationViewController(_ viewController: ConfigurationViewController,
                                     didUpdateAlgorithm algorithm: Algorithm) {
        self.algorithm = algorithm
    }
}

// MARK: - VideoCaptureDelegate

extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        poseNet.predict(image)
    }
}

// MARK: - PoseNetDelegate


extension ViewController: PoseNetDelegate {
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
            // Release `currentFrame` when exiting this method.
            self.currentFrame = nil
        }

        guard let currentFrame = currentFrame else {
            return
        }

        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)

        let poses = algorithm == .single
            ? [poseBuilder.pose]
            : poseBuilder.poses
        
        if !poses.isEmpty {
            let pose = poses[0]
   
            let left_hip_y = Float(pose.joints[.leftHip]?.position.y ?? 0) * 12
            let left_knee_y = Float(pose.joints[.leftKnee]?.position.y ?? 0) * 12
            let left_ankle_y = Float(pose.joints[.leftAnkle]?.position.y ?? 0) * 12
            let left_ear_y = Float(pose.joints[.leftEar]?.position.y ?? 0 ) * 12
            let left_eye_y = Float(pose.joints[.leftEye]?.position.y ?? 0) * 12
 
            let right_hip_y = Float(pose.joints[.rightHip]?.position.y ?? 0) * 12
            let right_knee_y = Float(pose.joints[.rightKnee]?.position.y ?? 0) * 12
            let right_ankle_y = Float(pose.joints[.rightAnkle]?.position.y ?? 0) * 12
            let right_ear_y = Float(pose.joints[.rightEar]?.position.y ?? 0) * 12
            let right_eye_y = Float(pose.joints[.rightEye]?.position.y ?? 0) * 12
            
            let nose_y = Float(pose.joints[.nose]?.position.y ?? 0) * 12
            
            self.current = [left_hip_y, left_knee_y, left_ankle_y, left_ear_y, left_eye_y, right_hip_y, right_knee_y, right_ankle_y, right_ear_y, right_eye_y, nose_y]
            let change = [130, 10, 0, 600, 650, 130, 10, 0, 600, 650, 550]
            var check = true
            
            for item in self.current{
                if item == Float(0){
                    check = false
                }
            }
            
            if check{
                if !self.previous.isEmpty {
                    let hips_check = abs(self.current[0] - self.previous[0]) >= Float(change[0]) && abs(self.current[5] - self.previous[5]) >= Float(change[5])
                    let knees_check = abs(self.current[1] - self.previous[1]) >= Float(change[1]) && abs(self.current[6] - self.previous[6]) >= Float(change[6])
                    let eyes_check = abs(self.current[4] - self.previous[4]) >= Float(change[4]) && abs(self.current[9] - self.previous[9]) >= Float(change[9])
                    if hips_check && knees_check && eyes_check {
                        var fall = 0
                        var rise = 0
                        
                        for x in 0..<self.current.count{
                            if self.current[x] > self.previous[x] {
                                fall += 1
                            } else{
                                rise += 1
                            }
                        }
        
                        let ans = rise >= fall ? "r" : "f"
                 
                        if self.oken == "r" && ans == "f" {
                            self.counter += 1
                            self.labelgudei.text = String(self.counter)
                        }
                        self.oken = ans
                    }
                }
                self.previous = self.current
            }
        }
        previewImageView.show(poses: poses, on: currentFrame)
    }
}
