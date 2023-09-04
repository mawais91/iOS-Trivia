//
//  GameService.swift
//  iOS Trivia
//
//  Created by Omar Albeik on 8/2/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import Foundation
import Moya

/// GameService
///
/// - question: get question.
enum GameService {
	case question(id: Int)
    case trivia(limit: Int)
}

extension GameService: TargetType {

	var baseURL: URL {
        switch self {
        case .question( _):
            return URL(string: "https://ios-trivia.firebaseio.com")!
        case .trivia(let limit):
            let categoryValue = UserDefaults.standard.string(forKey: CATEGORY_VALUE_KEY)
            let difficultyValue = UserDefaults.standard.string(forKey: DIFFICULTY_VALUE_KEY)
            var urlString = "https://opentdb.com/api.php" + "?amount=" + String(limit)
            if categoryValue != nil && categoryValue != "any" {
                urlString = urlString + "&category=" + categoryValue!
            }
            if difficultyValue != nil && difficultyValue != "any" {
                urlString = urlString + "&difficulty=" + difficultyValue!
            }
            return URL.init(string: urlString)!
        }
	}

	var path: String {
		switch self {
		case .question(let id):
			return "questions/q\(id).json"
        case .trivia(_):
            return ""
		}
	}

	var method: Moya.Method {
		switch self {
        case .question, .trivia:
			return .get
		}
	}

	var task: Task {
		switch self {
		case .question, .trivia:
			return .requestPlain
		}
	}

	var headers: [String: String]? { return nil }
	var sampleData: Data { return "".utf8Encoded }

}
