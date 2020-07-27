//
//  SquatViewController.swift
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/26/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

import UIKit

class SquatViewController: UIViewController {
    /// The view the controller uses to visualize the detected poses.
    @IBOutlet private var previewImageView: PoseImageView!
    @IBOutlet weak var timeCounter: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
