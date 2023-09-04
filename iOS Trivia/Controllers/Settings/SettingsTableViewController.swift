//
//  SettingsTableViewController.swift
//  iOS Trivia
//
//  Created by Muhammad  Awais on 12/10/19.
//  Copyright © 2019 Omar Albeik. All rights reserved.
//

import UIKit
import SwiftRater

class SettingsTableViewController: UITableViewController {
    
    //MARK: - Instance Variables
    var gameTypeData: GameTypeData!
    var categoryName: String = UserDefaults.standard.string(forKey: CATEGORY_NAME_KEY) ?? "Any Category"
    var categoryValue: String = UserDefaults.standard.string(forKey: CATEGORY_VALUE_KEY) ?? "any"
    var difficultyName: String = UserDefaults.standard.string(forKey: DIFFICULTY_NAME_KEY) ?? "Any Difficulty"
    var difficultyValue: String = UserDefaults.standard.string(forKey: DIFFICULTY_VALUE_KEY) ?? "any"
    var introView: SettingIntroView?
    var showIntro: Bool = false
    
    //MARK: - IBOutlets
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var difficultyNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        title = "SETTINGS"
        categoryNameLabel.text = categoryName
        difficultyNameLabel.text = difficultyName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showIntro {
            self.introView = SettingIntroView.instanceFromNib()
            let currentWindow: UIWindow? = UIApplication.shared.keyWindow
            if self.introView != nil {
                currentWindow?.addSubview(self.introView!)
            }
        }
        self.introView?.doneClickHandler = ({ [weak self] in
            self?.introView?.removeFromSuperview()
            self?.showIntro = false
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.introView?.removeFromSuperview()
    }
    
    //MARK: - Custom Methods
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            var gameTypeData = GameTypeData()
            if(indexPath.row == 0) {
                gameTypeData.gameType = .category
                gameTypeData.selectedName = categoryName
            } else if indexPath.row == 1 {
                gameTypeData.gameType = .difficulty
                gameTypeData.selectedName = difficultyName
            }
            self.gameTypeData = gameTypeData
            performSegue(withIdentifier: gameTypeData.segueIdentifier, sender: nil)
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                SwiftRater.rateApp(host: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameTypeVC = segue.destination as? GameTypeTableViewController {
            gameTypeVC.gameTypeData = self.gameTypeData
            gameTypeVC.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Color.white
    }
}

extension SettingsTableViewController: GameTypeDelegate {
    func didSelecte(name: String, value: String) {
        if self.gameTypeData.gameType == .category {
            categoryNameLabel.text = name
            categoryName = name
            UserDefaults.standard.set(name, forKey: CATEGORY_NAME_KEY)
            UserDefaults.standard.set(value, forKey: CATEGORY_VALUE_KEY)
        }
        if self.gameTypeData.gameType == .difficulty {
            difficultyNameLabel.text = name
            difficultyName = name
            UserDefaults.standard.set(name, forKey: DIFFICULTY_NAME_KEY)
            UserDefaults.standard.set(value, forKey: DIFFICULTY_VALUE_KEY)
        }
    }
}
