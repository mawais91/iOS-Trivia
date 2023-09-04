//
//  WelcomeView.swift
//  iOS Trivia
//
//  Created by Omar Albeik on 8/1/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import UIKit
import FontAwesome_swift
import GoogleMobileAds

final class WelcomeView: LayoutableView {

	lazy var startButton: Button = {
		return Button(title: L10n.Welcome.startGame)
	}()

	lazy var scoreboardButton: Button = {
		return Button(title: L10n.Welcome.scoreboard)
	}()
    
    var bannerView:GADBannerView!
    
    lazy var totalScoreLabel: UILabel = {
        var scoreLabel = UILabel()
        scoreLabel.textColor = Color.white
        scoreLabel.text = "Total score: 0"
        return scoreLabel
    }()
    
	lazy var buttonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [startButton, scoreboardButton])
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fillEqually
		view.spacing = preferredPadding / 3
		return view
	}()

	override var backgroundColor: UIColor? {
		didSet {
			
		}
	}

	override func setupViews() {
		backgroundColor = Color.lightOrange
		addSubview(buttonsStackView)
//        addSubview(totalScoreLabel)
        setBannerView()
        addBannerViewToView(bannerView)
    }
    
    func setBannerView() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        var unitId: String! = ""
        #if targetEnvironment(simulator)
        unitId = "ca-app-pub-3940256099942544/2934735716"
        #else
        unitId = BANNER_UNIT
        #endif
        bannerView.adUnitID = unitId
        if let topViewController = UIApplication.getTopViewController() {
            bannerView.rootViewController = topViewController
        }
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        addSubview(bannerView)
    }

	override func setupLayout() {
		startButton.snp.makeConstraints { $0.height.equalTo(preferredPadding * 2.2) }
		scoreboardButton.snp.makeConstraints { $0.height.equalTo(preferredPadding * 2.2) }
		buttonsStackView.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.leading.trailing.equalToSuperview().inset(preferredPadding * 1.5)
		}
        bannerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
	}
}

extension WelcomeView: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
}
