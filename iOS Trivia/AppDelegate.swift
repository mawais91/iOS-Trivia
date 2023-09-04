//
//  AppDelegate.swift
//  iOS Trivia
//
//  Created by Omar Albeik on 8/1/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftRater

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
    var gameCenterLoginController: UIViewController?
    
    let leaderboardId = "com.app.iostrivia.leaderboard.highscore"
    
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		setupWindow()
        GameCenterManager.shared()?.setupManager()
        GameCenterManager.shared()?.delegate = self
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        SwiftRater.daysUntilPrompt = 3
        SwiftRater.usesUntilPrompt = 7
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.showLog = true
        SwiftRater.debugMode = true // need to set false when submitting to AppStore!!
        SwiftRater.appLaunched()
		return true
	}

}

// MARK: - Setup
private extension AppDelegate {
	func setupWindow() {
		window = UIWindow()
		showWelcomeViewController(animated: false)
		window?.makeKeyAndVisible()
	}
}


extension AppDelegate {
    func showWelcomeViewController(animated: Bool = true) {
		let viewController = UINavigationController(rootViewController: WelcomeViewController())
		window?.switchRootViewController(to: viewController, animated: animated, options: .transitionFlipFromRight)
	}
    
    func showLeaderBoard() {
        if let topViewController = UIApplication.getTopViewController() {
            if let gcAvailable = GameCenterManager.shared()?.isGameCenterAvailable {
                if gcAvailable {
                    
                    GameCenterManager.shared()?.presentLeaderboards(on: topViewController, withLeaderboard: leaderboardId)
                } else {
                    guard let gcVC = gameCenterLoginController else {
                        return
                    }
                    topViewController.present(gcVC, animated: true, completion:nil)
                }
            } else {
                guard let gcVC = gameCenterLoginController else {
                    return
                }
                topViewController.present(gcVC, animated: true, completion:nil)
            }
        }
    }
}

extension AppDelegate {
    func saveScore(score: Int64) {
        if let gcAvailable = GameCenterManager.shared()?.isGameCenterAvailable {
            if gcAvailable {
                GameCenterManager.shared()?.saveAndReportScore(score, leaderboard: leaderboardId, sortOrder: GameCenterSortOrderHighToLow)
            }
        }
    }
}

extension AppDelegate: GameCenterManagerDelegate {
    func gameCenterManager(_ manager: GameCenterManager!, authenticateUser gameCenterLoginController: UIViewController!) {
        self.gameCenterLoginController = gameCenterLoginController
    }
}

extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
