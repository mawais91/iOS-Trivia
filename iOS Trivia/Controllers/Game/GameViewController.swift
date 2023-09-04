//
//  GameViewController.swift
//  iOS Trivia
//
//  Created by Omar Albeik on 8/1/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol GameViewControllerDelegate: class {
    func didFinishGame(score: Int)
}

final class GameViewController: LayoutingViewController, Layouting, Confettiable {
	typealias ViewType = GameView

	weak var timer: Timer?
    var totalPoints: Int = 0
    weak var delegate: GameViewControllerDelegate?
    var availableChances = 3
    var interstitial: GADInterstitial!

	var remainingTime: TimeInterval = 0 {
		didSet {
			layoutableView.timerView.configure(reminingTime: remainingTime, maxTime: currentQuestion.duration)
		}
	}

	var numberOfQuestions = 10
	var remainingIds: [Int] = []
    var questions: [Question] = []
    
	var currentQuestion: Question! {
		didSet {
			remainingTime = currentQuestion.duration
		}
	}

	var usedWildCards = 0 {
		didSet {
			layoutableView.useWildCardButton.isEnabled = (usedWildCards < numberOfWildCards)
		}
	}
	let numberOfWildCards = 3

	override func loadView() {
		view = ViewType()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

        numberOfQuestions = questions.count
        
		layoutableView.answersView.delegate = self

		layoutableView.useWildCardButton.addTarget(self, action: #selector(didTapUseWildCardButton), for: .touchUpInside)
        
        var unitId: String! = ""
        #if targetEnvironment(simulator)
          unitId = "ca-app-pub-3940256099942544/4411468910"
        #else
          unitId = INTERSTITIAL_UNIT
        #endif
        interstitial = GADInterstitial(adUnitID: unitId)
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		fetchNextQuestion(sender: layoutableView)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		timer?.invalidate()
	}

	override func setNavigationItem() {
		navigationController?.navigationBar.setColors(background: Color.lightOrange, text: Color.white)
		navigationItem.replaceTitle(with: #imageLiteral(resourceName: "nav_logo"))
		navigationItem.leftBarButtonItem = .init(image: #imageLiteral(resourceName: "nav_icon_close"), style: .plain, target: self, action: #selector(didTapCancelBarButtonItem))
	}
}

// MARK: - AnswersViewDelegate
extension GameViewController: AnswersViewDelegate {

	func answersView(_ view: AnswersView, didSelectAnswerAtIndex index: Int) {
		guard let question = currentQuestion else { return }
		submitAnswer(sender: layoutableView, index: index, in: question)
	}

}

// MARK: - Actions
private extension GameViewController {

	@objc
	func didTapCancelBarButtonItem() {
		guard !questions.isEmpty else {
			dismiss(animated: true)
			return
		}

		let alert = UIAlertController(title: L10n.Game.QuitAlert.title, message: nil, preferredStyle: .alert)

		let quitAction = UIAlertAction(title: L10n.Game.QuitAlert.Options.quit, style: .destructive) { [weak self] _ in
            self?.showResultViewController(sender: nil)
		}

		let stayAction = UIAlertAction(title: L10n.Game.QuitAlert.Options.stay, style: .cancel, handler: nil)

		alert.addAction(quitAction)
		alert.addAction(stayAction)

		alert.view.tintColor = Color.darkBlack
		present(alert, animated: true)
	}

	@objc
	func didTapUseWildCardButton() {
		guard let correctAnswerIndex = currentQuestion.answers.index(where: { $0.isCorrect }) else { return }
		layoutableView.answersView.selectAnswer(atIndex: correctAnswerIndex)
		usedWildCards += 1
	}

}

// MARK: - Timer Helpers
private extension GameViewController {

	func scheduledQuestionTimer() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTime(_:)), userInfo: nil, repeats: true)
	}

	@objc
	func updateTime(_ timer: Timer) {
		guard remainingTime > 0 else {
			timer.invalidate()
			fetchNextQuestion(sender: layoutableView)
			return
		}

		remainingTime -= 0.001
	}

}

// MARK: - Networking
private extension GameViewController {

	func submitAnswer(sender: Loadingable, index: Int, in question: Question) {
		let points = question.answers[index].isCorrect ? question.points : 0
        totalPoints += points
        sender.setLoading(true)
        let secs = randomNumber()
        if !question.answers[index].isCorrect {
            availableChances -= 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + secs) {
            // your code here
            self.timer?.invalidate()
            if question.answers[index].isCorrect {
                self.showRightAnswerAlert(points: question.points)
            } else {
                self.showWrongAnswerAlert()
            }
            self.scheduledQuestionTimer()
            sender.setLoading(false)
            self.fetchNextQuestion(sender: sender)
        }
	}

	func fetchNextQuestion(sender: Loadingable) {
		guard let question = questions.popLast() else {
            sender.setLoading(true)
            fetchMoreQuestions(sender: sender)
			return
		}
        if availableChances <= 0 {
            showResultViewController(sender: sender)
        } else {
            timer?.invalidate()
            sender.setLoading(true)
            self.updateView(question: question)
            sender.setLoading(false)
        }
	}
    
    func showResultViewController(sender: Loadingable?) {
        var delay: TimeInterval = 0
        if sender != nil {
            delay = 3
        }
        if interstitial.isReady {
            sender?.setLoading(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                sender?.setLoading(false)
                self.interstitial.present(fromRootViewController: self)
            }
        } else {
            sender?.setLoading(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.dismiss(animated: false, completion: {
                    sender?.setLoading(false)
                    self.delegate?.didFinishGame(score: self.totalPoints)
                })
            }
        }
    }
    
    func fetchMoreQuestions(sender: Loadingable) {
        let decoder = DefaultDecoder()
        decoder.setDefaultCase()
        API.gameProvider.request(.trivia(limit: 10), dataType: Welcome.self, decoder: decoder) { [weak self] result in
            guard let strongSelf = self else { return }
            sender.setLoading(false)
            switch result {
            case .failure( _):
                DispatchQueue.main.async {
                    strongSelf.showResultViewController(sender: sender)
                }
            case .success(let data):
                print(data)
                strongSelf.questions = self?.converResultsToQuestions(results: data.results) ?? []
                DispatchQueue.main.async {
                    strongSelf.fetchNextQuestion(sender: sender)
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

	func updateView(question: Question) {
		currentQuestion = question
		layoutableView.configure(for: question)
//		let answeredCount = numberOfQuestions - questions.count
		let wildCardsCount = numberOfWildCards - usedWildCards
		layoutableView.configureHeader(question: availableChances, maxQuestions: 3, wildCard: wildCardsCount, maxWildCards: numberOfWildCards)
		scheduledQuestionTimer()
		layoutableView.useWildCardButton.isHidden = false
	}
    
    func randomNumber() -> Double {
        let secsArray: [Double] = [0.5, 0.7, 0.9, 1.11, 1.13, 1.15, 1.17, 2]
        return secsArray.randomElement()!
    }

}

// MARK: - Helpers
private extension GameViewController {

	func showRightAnswerAlert(points: Int) {
		Alert(body: L10n.Game.Messages.rightAnswer(points), layout: .statusLine, theme: .success).show()
		showConfetti()
	}

	func showWrongAnswerAlert() {
		Alert(body: L10n.Game.Messages.wrongAnswer, layout: .statusLine, theme: .error).show()
	}
}

extension GameViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.dismiss(animated: false, completion: {
            self.delegate?.didFinishGame(score: self.totalPoints)
        })
    }
}
