//
//  WelcomeViewController.swift
//  iOS Trivia
//
//  Created by Omar Albeik on 8/1/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import UIKit
import FontAwesome_swift
import GoogleMobileAds

final class WelcomeViewController: UIViewController, Layouting {
    
	typealias ViewType = WelcomeView
    var introView: WelcomeIntroView?
    var showIntro: Bool = false
    
    
	override func loadView() {
		view = ViewType()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		layoutableView.startButton.addTarget(self, action: #selector(didTapStartButton(_:)), for: .touchUpInside)
		layoutableView.scoreboardButton.addTarget(self, action: #selector(didTapScoreboardButton(_:)), for: .touchUpInside)
	}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !(UserDefaults.standard.bool(forKey: INTRO_PAGE_SHOWN)) {
            self.introView = WelcomeIntroView.instanceFromNib()
            let currentWindow: UIWindow? = UIApplication.shared.keyWindow
            if self.introView != nil {
                currentWindow?.addSubview(self.introView!)
            }
            self.introView?.settingClickHandler = ({ [weak self] in
                self?.showIntro = true
                self?.didTapSettingButton()
                self?.introView?.removeFromSuperview()
                UserDefaults.standard.set(true, forKey: INTRO_PAGE_SHOWN)
            });
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.introView?.removeFromSuperview()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.setColors(background: Color.lightOrange, text: Color.white)
        let settingImage = UIImage.fontAwesomeIcon(name: .cogs, style: .solid, textColor: UIColor.white, size: CGSize(width: 40, height: 40))
        navigationItem.rightBarButtonItem = .init(image: settingImage, style: .plain, target: self, action: #selector(didTapSettingButton))
        let totalPoints: Int = UserDefaults.standard.integer(forKey: HIGHEST_SCORE)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Best: " + String(totalPoints), style: .plain, target: nil, action: nil)
	}
}

// MARK: - Actions
private extension WelcomeViewController {

	@objc
	func didTapStartButton(_ button: Button) {
		showGameViewController(sender: button)
	}

	@objc
	func didTapScoreboardButton(_ button: Button) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.showLeaderBoard()
        }
	}
    
    @objc
    func didTapSettingButton() {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let settingVC = storyBoard.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
        settingVC.view.backgroundColor = Color.lightOrange
        settingVC.showIntro = self.showIntro
        self.navigationController?.pushViewController(settingVC, animated: true)
        self.showIntro = false
    }
}

// MARK: - Helpers
private extension WelcomeViewController {

    func showGameViewController(sender: Loadingable) {
        fetchQuestions(sender: sender)
	}
    
    func fetchQuestions(sender: Loadingable) {
        let decoder = DefaultDecoder()
        decoder.setDefaultCase()
        sender.setLoading(true)
        API.gameProvider.request(.trivia(limit: 20), dataType: Welcome.self, decoder: decoder) { [weak self] result in
            guard let strongSelf = self else { return }
            sender.setLoading(false)
            switch result {
            case .failure(let error):
                strongSelf.dismiss(animated: true)
                Alert(serverError: error).show()
            case .success(let data):
                print(data)
                let gameViewController = GameViewController()
                gameViewController.questions = self?.converResultsToQuestions(results: data.results) ?? []
                gameViewController.delegate = self
                let navController = UINavigationController(rootViewController: gameViewController)
                navController.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async {
                    self?.present(navController, animated: true)
                }
                break
            }
        }
    }
    
    func converResultsToQuestions(results: [ResultO]) -> [Question] {
        var count = 0
        var questions: [Question] = []
        
        for result in results {
            var answers: [Answer] = []
            for answer in result.incorrectAnswers! {
                let ans = Answer(text: answer, isCorrect: false)
                answers.append(ans)
            }
            let answer = Answer(text: result.correctAnswer!, isCorrect: true)
            answers.append(answer)
            answers.shuffle()
            let question = Question(id: String(count), text: result.question!, duration: result.duration, points: 10, answers: answers)
            count += 1
            questions.append(question)
        }
        
        return questions
    }

}

// MARK: - Networking
private extension WelcomeViewController {
    
}

extension WelcomeViewController: GameViewControllerDelegate {
    func didFinishGame(score: Int) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let scoreBoardVC = storyBoard.instantiateViewController(withIdentifier: "ScoreboardViewController") as? ScoreboardViewController
        scoreBoardVC?.score = score
        scoreBoardVC?.delegate = self
        navigationController?.pushViewController(scoreBoardVC!, animated: true)
    }
}

extension WelcomeViewController: ScoreBoardViewControllerDelegate {
    func didChoosePlayAgain() {
        didTapStartButton(layoutableView.startButton)
    }
    func didChooseLeaderBoard() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.showLeaderBoard()
        }
    }
}
