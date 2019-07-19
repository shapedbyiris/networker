//
//  APIRequests.swift
//  HTTPClient
//
//  Created by Ariel Elkin on 19/07/2019.
//  Copyright © 2019 IRIS. All rights reserved.
//

import Foundation

public protocol APIRequest {
    var request: URLRequest { get }
    associatedtype SuccessfulResponseDataType: Codable
    associatedtype ErrorResponseDataType: Error & Codable
}

public enum APIError: Error {
    case noDataAndNoError
    case failedToDecodeError
}

extension Optional where Wrapped: URLResponse {
    var isSuccess: Bool {
        if let statusCode = (self as? HTTPURLResponse)?.statusCode {
            return statusCode >= 200 && statusCode < 400
        }
        return false
    }
}

public class APIRequestLoader<T: APIRequest> {
    let apiRequest: T
    let urlSession: URLSession

    init(apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }

    @discardableResult
    func perform(completionHandler: @escaping (Result<T.SuccessfulResponseDataType, Error>) -> Void) -> URLSessionTask {
        let task = urlSession.dataTask(with: apiRequest.request) { (data, response, error) in

            guard let data = data else {
                let error = error ?? APIError.noDataAndNoError
                completionHandler(.failure(error))
                return
            }

            if response.isSuccess {
                do {
                    let parsedResponse = try JSONDecoder().decode(T.SuccessfulResponseDataType.self, from: data)
                    completionHandler(.success(parsedResponse))
                } catch {
                    completionHandler(.failure(error))
                }
            } else {
                if let error = error {
                    completionHandler(.failure(error))
                } else if let error = try? JSONDecoder().decode(T.ErrorResponseDataType.self, from: data) {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.failure(APIError.failedToDecodeError))
                }
            }
        }
        task.resume()
        return task
    }
}
