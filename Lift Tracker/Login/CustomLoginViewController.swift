//
//  CustomLoginViewController.swift
//  Lift Tracker
//
//  Created by Carl Burnham on 2/9/19.
//  Copyright © 2019 Carl Burnham. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI

class CustomLoginViewController: FUIAuthPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iconImage = UIImage(named: "loginScreenIcon")
        
        let width = UIScreen.main.bounds.size.width
        
        let imageSize: CGFloat = 150.0
        let startImageX = (width / 2.0) - (imageSize / 2.0)
        let imageView = UIImageView(frame: CGRect(x: startImageX, y: 110, width: imageSize, height: imageSize))
        imageView.backgroundColor = .black
        imageView.image = iconImage
        imageView.layer.cornerRadius = 12.0
        imageView.clipsToBounds = true

        self.view.insertSubview(imageView, at: 0)
        self.view.backgroundColor = .white
    }
}
