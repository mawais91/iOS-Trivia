//
//  Question.swift
//  iOS Trivia
//
//  Created by Omar Albeik on 8/2/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import Foundation

/// Question model.
public struct Question: Codable {

	public var id: String
	public var text: String
	public var duration: TimeInterval
	public var points: Int
	public var answers: [Answer]

}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

// MARK: - Welcome
struct Welcome: Codable {
    let responseCode: Int
    let results: [ResultO]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

// MARK: - Result
struct ResultO: Codable {
    let category: String?
    let type: TypeEnum?
    let difficulty: Difficulty?
    let question, correctAnswer: String?
    let incorrectAnswers: [String]?
    let duration: TimeInterval = 30
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

enum Difficulty: String, Codable {
    case easy = "easy"
    case hard = "hard"
    case medium = "medium"
}

enum TypeEnum: String, Codable {
    case boolean = "boolean"
    case multiple = "multiple"
}

