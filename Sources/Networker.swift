//
//  Networker.swift
//  HTTPClient
//
//  Created by Ariel Elkin on 19/07/2019.
//  Copyright © 2019 IRIS. All rights reserved.
//

import Foundation

public protocol APIRequest {
    var request: URLRequest { get }

    associatedtype SuccessfulResponseDataType: Decodable
    associatedtype ErrorResponseDataType: Error & Decodable
}

public enum APIError: Error {
    case noDataAndNoError
    case failedToDecodeError(statusCode: Int?, body: Data)
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
    public let apiRequest: T
    public let urlSession: URLSession

    public init(apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }

    @discardableResult //swiftlint:disable:next line_length
    public func perform(completionHandler: @escaping (Result<T.SuccessfulResponseDataType, Error>) -> Void) -> URLSessionDataTask {
        let task = urlSession.dataTask(with: apiRequest.request) { data, response, error in

            guard error == nil else {
                completionHandler(.failure(error!))
                return
            }

            guard let data = data else {
                completionHandler(.failure(APIError.noDataAndNoError))
                return
            }

            if response.isSuccess {
                do {
                    let parsedResponse = try JSONDecoder().decode(T.SuccessfulResponseDataType.self, from: data)
                    completionHandler(.success(parsedResponse))
                } catch {
                    completionHandler(.failure(error))
                }
            } else if let error = try? JSONDecoder().decode(T.ErrorResponseDataType.self, from: data) {
                completionHandler(.failure(error))
            } else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                completionHandler(.failure(APIError.failedToDecodeError(statusCode: statusCode, body: data)))
            }
        }
        task.resume()
        return task
    }
}

extension APIRequest {
    @discardableResult //swiftlint:disable:next line_length
    public func perform(urlSession: URLSession = .shared, completionHandler: @escaping (Result<SuccessfulResponseDataType, Error>) -> Void) -> URLSessionDataTask {
        let loader = APIRequestLoader(apiRequest: self, urlSession: urlSession)
        return loader.perform(completionHandler: completionHandler)
    }
}
