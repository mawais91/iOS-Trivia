//
//  ScoreboardViewController.swift
//  iOS Trivia
//
//  Created by Omar Albeik on 8/3/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import UIKit
import FontAwesome_swift

protocol ScoreBoardViewControllerDelegate: class {
    func didChoosePlayAgain()
    func didChooseLeaderBoard()
}

class ScoreboardViewController: UIViewController {
    
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var leaderboardButton: UIButton!
    
    var score: Int = 0
    weak var delegate: ScoreBoardViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let highestScore: Int = UserDefaults.standard.integer(forKey: HIGHEST_SCORE)
        if (score > highestScore) {
            UserDefaults.standard.set(score, forKey: HIGHEST_SCORE)
            (UIApplication.shared.delegate as? AppDelegate)?.saveScore(score: Int64(score))
        }
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scoreView.layer.cornerRadius = 5
        scoreView.layer.masksToBounds = true
    }
    
    func setupUI() {
        homeButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .solid)
        homeButton.setTitle(String.fontAwesomeIcon(name: .home), for: .normal)
        playButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .solid)
        playButton.setTitle(String.fontAwesomeIcon(name: .redo), for: .normal)
        leaderboardButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .solid)
        leaderboardButton.setTitle(String.fontAwesomeIcon(name: .chartBar), for: .normal)
        self.navigationItem.setHidesBackButton(true, animated:true);
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scoreView.addSubview(blurEffectView)
        scoreLabel.text = String(score)
    }
    
    //MARK: Action Methods
    
    @IBAction func didTapHome(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapPlayAgain(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
        delegate?.didChoosePlayAgain()
    }
    
    @IBAction func diidTapScores(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
        delegate?.didChooseLeaderBoard()
    }
}
