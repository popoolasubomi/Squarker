//
//  SquatViewController.swift
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/26/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

import UIKit
import UIKit
import VideoToolbox

class SquatViewController: UIViewController, ConfigurationViewControllerDelegate, VideoCaptureDelegate, PoseNetDelegate {

    /// The view the controller uses to visualize the detected poses.
    @IBOutlet private var previewImageView: PoseImageView!
    @IBOutlet weak var timeCounter: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    var counter = 0 // Counter for Squats
    var previous = [Float]()    // Previous data of squats
    var current = [Float]() // Current Squatting data
    var previous_action: String = "r"    // Current State of body
    
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if !(segue.destination is PostViewController){
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
        else{
            let postController = segue.destination as! PostViewController
            postController.numSquats = NSNumber(value: self.counter)
        }
    }
    
    // MARK: - ConfigurationViewControllerDelegate
    
    func configurationViewController(_ viewController: ConfigurationViewController, didUpdateConfiguration configuration: PoseBuilderConfiguration) {
        poseBuilderConfiguration = configuration
    }
    
    func configurationViewController(_ viewController: ConfigurationViewController, didUpdateAlgorithm algorithm: Algorithm) {
        self.algorithm = algorithm
    }
    
    // MARK: - VideoCaptureDelegate
    
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
    
    // MARK: - PoseNetDelegate
    
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

        let poses = algorithm == .single ? [poseBuilder.pose] : poseBuilder.poses // Returns 2D array with a single element
        previewImageView.show(poses: poses, on: currentFrame)
    }
}







