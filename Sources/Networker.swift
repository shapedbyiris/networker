//
//  Networker.swift
//  HTTPClient
//
//  Created by Ariel Elkin on 19/07/2019.
//  Copyright © 2019 IRIS. All rights reserved.
//

import Foundation
import Combine

public protocol APIRequest {
    var request: URLRequest { get }

    associatedtype SuccessfulResponseDataType: Decodable
    associatedtype ErrorResponseDataType: Error & Decodable
}

extension URLResponse {
    var isSuccess: Bool {
        if let statusCode = (self as? HTTPURLResponse)?.statusCode {
            return statusCode >= 200 && statusCode < 400
        }
        return false
    }
}

open class APIRequestLoader<T: APIRequest> {
    public let apiRequest: T
    public let urlSession: URLSession

    public init(_ apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }

    open func perform() -> AnyPublisher<T.SuccessfulResponseDataType, Error> {
        return urlSession.dataTaskPublisher(for: self.apiRequest.request)
            .tryMap { data, response -> Data in
                if response.isSuccess {
                    return data
                } else {
                    let apiError = try JSONDecoder().decode(T.ErrorResponseDataType.self, from: data)
                    throw apiError
                }
            }
            .decode(type: T.SuccessfulResponseDataType.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
