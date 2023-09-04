//
//  Moya+Extensions.swift
//  iOS Trivia
//
//  Created by Omar Albeik on 8/3/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import Foundation
import Moya
import Result

public extension MoyaProvider {

    func request<T: Codable>(_ target: Target, dataType: T.Type, decoder: JSONDecoder? = nil, completion: @escaping (_ result: Result<T, APIError>) -> Void) {
		request(target) { result in
			switch result {
			case .failure(let error):
				completion(.failure(.error(error)))
			case .success(let response):
                var jsonDecoder: JSONDecoder!
                if let decoderJson = decoder {
                    jsonDecoder = decoderJson
                } else {
                    jsonDecoder = DefaultDecoder()
                }
				guard let data = try? response.map(T.self, using: jsonDecoder) else {
					let message = (try? response.map(ErrorResult.self, atKeyPath: "error"))?.message ?? L10n.Api.Errors.serverError
					completion(.failure(.serverError(message: message)))
					return
				}

				completion(.success(data))
			}
		}
	}
}
