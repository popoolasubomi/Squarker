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
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var squatCounter = 0 // Counter for Squats
    var timeCounter = UserDefaults.standard.integer(forKey: "Time") // Counter for Time
    var previous = [Float]()    // Previous data of squats
    var current = [Float]() // Current Squatting data
    var previous_action: String = "r"    // Current State of body
    var timer = Timer() // Timer For Squat App
    var working = false
    
    var guideView: UIView!
    var nextBtn: UIButton!
    var prevBtn: UIButton!
    var skipBtn: UIButton!
    var btnLoc = 0
    var instruction: UILabel!
    var instructions = [String]()
    
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
        self.instructions = ["Place Phone on the ground & Allow to rest on a vertical structure", "Before you squat, Allow the phone to capture your entire body so u see point markings from your head to ankle", "If haven't, configure the time for squats required & set your height by clicking settings on the top right corner", "Press next to continue to the start button"]
        buildInstructionController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        UIApplication.shared.isIdleTimerDisabled = true

        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }
        
        poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()
        
        editRoundButton()
    }
    
    func buildInstructionController() {
        self.guideView = UIView()
        self.guideView.backgroundColor = .white
        self.guideView.layer.cornerRadius = 17
        self.guideView.layer.masksToBounds = true
        
        self.nextBtn = UIButton()
        self.nextBtn.setTitleColor(.blue, for: .normal)
        self.nextBtn.setTitle("Next", for: .normal)
        self.nextBtn.addTarget(self, action: #selector(nextGuide), for: .touchUpInside)
        
        self.prevBtn = UIButton()
        self.prevBtn.setTitle("Previous", for: .normal)
        self.prevBtn.setTitleColor(.blue, for: .normal)
        self.prevBtn.addTarget(self, action: #selector(prevGuide), for: .touchUpInside)
        
        self.skipBtn = UIButton()
        self.skipBtn.setTitle("Skip", for: .normal)
        self.skipBtn.setTitleColor(.blue, for: .normal)
        self.skipBtn.addTarget(self, action: #selector(skipGuide), for: .touchUpInside)
        
        self.instruction = UILabel()
        self.instruction.textColor = .black
        self.instruction.text = self.instructions[self.btnLoc]
        self.instruction.numberOfLines = 0
        self.instruction.font = UIFont(name: "Cochin ", size: 25)
        self.instruction.textAlignment = .center
        
        var frame = guideView.frame
        frame.origin.x = 10.0
        frame.origin.y = 465.0
        frame.size.height = self.view.frame.size.height / 3
        frame.size.width = (self.view.frame.size.width - 20)
        guideView.frame = frame
        
        var nxtBtnFrame = frame
        nxtBtnFrame.origin.x = (frame.size.width - 60)
        nxtBtnFrame.origin.y = (frame.size.height - 70)
        nxtBtnFrame.size.width = 50.0
        nxtBtnFrame.size.height = 50.0
        self.nextBtn.frame = nxtBtnFrame
        
        var prvBtnFrame = frame
        prvBtnFrame.origin.x = 10
        prvBtnFrame.origin.y = (frame.size.height - 70)
        prvBtnFrame.size.width = 100.0
        prvBtnFrame.size.height = 50
        self.prevBtn.frame = prvBtnFrame
        
        var skipBtnFrame = frame
        skipBtnFrame.origin.x = (frame.size.width - 60)
        skipBtnFrame.origin.y = 10.0
        skipBtnFrame.size.width = 50.0
        skipBtnFrame.size.height = 20.0
        self.skipBtn.frame = skipBtnFrame
        
        var lblFrame = frame
        lblFrame.origin.x = 30.0
        lblFrame.origin.y = 10.0
        lblFrame.size.width = (frame.size.width - 60)
        lblFrame.size.height = (frame.size.height - 80)
        self.instruction.frame = lblFrame
        
        self.guideView.addSubview(self.nextBtn)
        self.guideView.addSubview(self.prevBtn)
        self.guideView.addSubview(self.instruction)
        self.guideView.addSubview(self.skipBtn)
        self.view.addSubview(self.guideView)
    }
    
    @objc func nextGuide(){
        if self.btnLoc + 1 == self.instructions.count{
            self.guideView.removeFromSuperview()
        }else{
            self.btnLoc += 1
            self.instruction.text = self.instructions[self.btnLoc]
        }
    }
    
    @objc func prevGuide(){
        if self.btnLoc - 1 >= 0{
            self.btnLoc -= 1
            self.instruction.text = self.instructions[self.btnLoc]
        }
    }
    
    @objc func skipGuide(){
        self.guideView.removeFromSuperview()
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        self.performSegue(withIdentifier: "settingsSegue", sender: nil);
    }
    
    func editRoundButton(){
        let y = self.view.frame.size.height - 250
        let x = (self.view.frame.size.width - 100) / 2
        self.startButton.frame = CGRect(x: x, y: y, width: 100, height: 100)
        self.startButton.clipsToBounds = true
        self.startButton.layer.cornerRadius = 100/2
    }
    
    @IBAction func postButton(_ sender: Any) {
        self.performSegue(withIdentifier: "postSegue", sender: nil)
    }
    
    @IBAction func beginSquatting(_ sender: Any) {
        self.working = self.working == true ? false : true
        if (self.working){
            self.startButton.setTitle("Stop", for: .normal)
            self.startButton.backgroundColor = UIColor.red
            timerType()
        } else{
            self.squatCounter = 0
            self.timeCounter = UserDefaults.standard.integer(forKey: "Time")
            self.startButton.setTitle("Start", for: .normal)
            self.startButton.backgroundColor = UIColor.green
            self.previous = [Float]()
            self.current = [Float]()
            self.previous_action = "r"
            self.timer.invalidate()
            
            self.timerLabel.text = "00:00"
            self.counterLabel.text = "0"
        }
    }
    
    func timerType(){
        self.timeCounter *= 60
        let minutes = "\(Int(self.timeCounter / 60))".count == 2 ? "\(Int(self.timeCounter / 60))" : "0\(Int(self.timeCounter / 60))"
        let seconds = "\(self.timeCounter % 60)".count == 2 ? "\(self.timeCounter % 60)" : "0\(self.timeCounter % 60)"
        self.timerLabel.text = String(format: "\(minutes):\(seconds)")
        
        if self.timeCounter != 0{
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        }else{
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countUp), userInfo: nil, repeats: true)
        }
    }
    
    @objc func countDown(){
        self.timeCounter -= 1
        let minutes = "\(Int(self.timeCounter / 60))".count == 2 ? "\(Int(self.timeCounter / 60))" : "0\(Int(self.timeCounter / 60))"
        let seconds = "\(self.timeCounter % 60)".count == 2 ? "\(self.timeCounter % 60)" : "0\(self.timeCounter % 60)"
        self.timerLabel.text = String(format: "\(minutes):\(seconds)")
        
        if self.timeCounter == 60{
            let lowerViews: GradientOverlayView = GradientOverlayView()
            lowerViews.startColor = UIColor.green
        }
        
        if self.timeCounter == 0{
            self.working = false
            self.timer.invalidate()
        }
    }
    
    @objc func countUp(){
        self.timeCounter += 1
        
        let minutes = "\(Int(self.timeCounter / 60))".count == 2 ? "\(Int(self.timeCounter / 60))" : "0\(Int(self.timeCounter / 60))"
        let seconds = "\(self.timeCounter % 60)".count == 2 ? "\(self.timeCounter % 60)" : "0\(self.timeCounter % 60)"
        self.timerLabel.text = String(format: "\(minutes):\(seconds)")
        
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
            postController.numSquats = NSNumber(value: self.squatCounter)
            let startTime = UserDefaults.standard.integer(forKey: "Time")
            let endTime = Int(self.timeCounter / 60)
            let interval = abs(startTime - endTime)
            postController.totalTime = NSNumber(value: interval)
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
        
        if !poses.isEmpty && working{
                   let pose = poses[0] // Take first array in Poses data
                   
                   // Get CGPoints of respectivec joints
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
                   
                   // Array of current squatting data
                   self.current = [left_hip_y, left_knee_y, left_ankle_y, left_ear_y, left_eye_y, right_hip_y, right_knee_y, right_ankle_y, right_ear_y, right_eye_y, nose_y]
                   // Array of minimum required change in current data and previous data
                   let change = [130, 10, 0, 600, 650, 130, 10, 0, 600, 650, 550]
                   var check = true
                   //Ensure that all points are sin and are non-zero
                   for item in self.current{
                       if item == Float(0){
                           check = false
                       }
                   }
                   
                   if check{
                       if !self.previous.isEmpty { //If previous points do exist
                           //check if change btw previous data and current data meet minimum required value
                           let hips_check = abs(self.current[0] - self.previous[0]) >= Float(change[0]) && abs(self.current[5] - self.previous[5]) >= Float(change[5])
                           let knees_check = abs(self.current[1] - self.previous[1]) >= Float(change[1]) && abs(self.current[6] - self.previous[6]) >= Float(change[6])
                           let eyes_check = abs(self.current[4] - self.previous[4]) >= Float(change[4]) && abs(self.current[9] - self.previous[9]) >= Float(change[9])
                           
                           if hips_check && knees_check && eyes_check { // If it does meet minimum required value
                               var fall = 0
                               var rise = 0
                               //Get number of data points that rise and fall
                               for x in 0..<self.current.count{
                                   fall = self.current[x] > self.previous[x] ? fall + 1 : fall
                                   rise = self.current[x] < self.previous[x] ? rise + 1 : rise
                               }
               
                               let current_action = rise >= fall ? "r" : "f" // Compare rise and fall values to determine if body is really falling or rising
                        
                               if self.previous_action == "r" && current_action == "f" { //When body is rising after a squat, increment counter by 1
                                   self.squatCounter += 1
                                   self.counterLabel.text = String(self.squatCounter)
                               }
                               self.previous_action = current_action //Assign current action to previous action
                           }
                       }
                       self.previous = self.current // Assign current data to previous data
                   }
               }
        
        previewImageView.show(poses: poses, on: currentFrame)
    }
}







