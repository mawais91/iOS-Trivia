//
//  WelcomeIntroView.swift
//  iOS Trivia
//
//  Created by Muhammad  Awais on 12/13/19.
//  Copyright © 2019 Omar Albeik. All rights reserved.
//

import UIKit
import SwiftyGif

typealias settingClickBlock = ()->()

class WelcomeIntroView: UIView {
    
    @IBOutlet weak var introImageView: UIImageView!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    var settingClickHandler: settingClickBlock?
    
    class func instanceFromNib() -> WelcomeIntroView? {
        return UINib(nibName: "WelcomeIntroView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WelcomeIntroView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gif = try? UIImage(gifName: "arrow.gif") {
            self.introImageView.setGifImage(gif)
        }
        self.frame = UIScreen.main.bounds
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("IPHONE 5,5S,5C")
            case 1334:
                print("IPHONE 6,7,8 IPHONE 6S,7S,8S ")
            case 1920, 2208:
                print("IPHONE 6PLUS, 6SPLUS, 7PLUS, 8PLUS")
            case 2436:
                topMargin.constant = 100
                print("IPHONE X, IPHONE XS")
            case 2688:
                print("IPHONE XS_MAX")
                topMargin.constant = 100
            case 1792:
                print("IPHONE XR")
                topMargin.constant = 100
            default:
                print("UNDETERMINED")
                topMargin.constant = 100
            }
        }
    }
    
    @IBAction func didTapSettings(_ sender: UIButton) {
        if let settingClickHandler = settingClickHandler {
            settingClickHandler()
        }
    }
}
