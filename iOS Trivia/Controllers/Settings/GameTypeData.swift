//
//  GameTypeData.swift
//  iOS Trivia
//
//  Created by Muhammad  Awais on 12/11/19.
//  Copyright © 2019 Omar Albeik. All rights reserved.
//

import UIKit

enum GameType: String {
    case category
    case difficulty
    case type
}

struct GameTypeData {
    
    var segueIdentifier: String!
    var title: String!
    var selectedName:String?
    
    var gameType: GameType = .category {
        didSet {
            segueIdentifier = gameType.rawValue
            switch gameType {
            case .category:
                title = "Select Category"
                dataArray = [["name": "Any Category", "value": "any"], ["name": "General Knowledge", "value": "9"], ["name": "Books", "value": "10"], ["name": "Film", "value": "11"], ["name": "Music", "value": "12"], ["name": "Musical & Theaters", "value": "13"], ["name": "Television", "value": "14"], ["name": "Video Games", "value": "15"], ["name": "Board Games", "value": "16"], ["name": "Science & Nature", "value": "17"], ["name": "Science: Computers", "value": "18"], ["name": "Science: Mathematics", "value": "19"], ["name": "Mythology", "value": "20"], ["name": "Sports", "value": "21"], ["name": "Geography", "value": "22"], ["name": "History", "value": "23"], ["name": "Politics", "value": "24"],["name": "Art", "value": "25"], ["name": "Celebrities", "value": "26"], ["name": "Animals", "value": "27"], ["name": "Vehicles", "value": "28"], ["name": "Comics", "value": "29"], ["name": "Science: Gadgets", "value": "30"], ["name": "Japanese Anime & Manga", "value": "31"], ["name": "Cartoon & Animations", "value": "32"]]
            case .difficulty:
                title = "Select Difficulty Level"
                dataArray = [["name": "Any Difficulty", "value": "any"], ["name": "Easy", "value": "easy"], ["name": "Medium", "value": "medium"], ["name": "Hard", "value": "hard"]]
            default:
                break
            }
        }
    }
    
    var dataArray: [[String:String]]!
}
