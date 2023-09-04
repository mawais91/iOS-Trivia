//
//  SettingIntroView.swift
//  iOS Trivia
//
//  Created by Muhammad  Awais on 12/13/19.
//  Copyright © 2019 Omar Albeik. All rights reserved.
//

import UIKit

typealias doneClickBlock = ()->()

class SettingIntroView: UIView {
    
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    var doneClickHandler: doneClickBlock?
    
    class func instanceFromNib() -> SettingIntroView? {
        return UINib(nibName: "SettingIntroView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SettingIntroView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
                topMargin.constant = 232
                print("IPHONE X, IPHONE XS")
            case 2688:
                print("IPHONE XS_MAX")
                topMargin.constant = 232
            case 1792:
                print("IPHONE XR")
                topMargin.constant = 232
            default:
                print("UNDETERMINED")
                topMargin.constant = 232
            }
        }
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        if let doneClickHandler = doneClickHandler {
            doneClickHandler()
        }
    }
}
