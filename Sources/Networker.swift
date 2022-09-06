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
    associatedtype ErrorResponseDataType: Error, Decodable
}

open class APIRequestLoader<T: APIRequest> {
    public let apiRequest: T
    public let urlSession: URLSession

    public init(_ apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }

    open func perform() async throws -> T.SuccessfulResponseDataType {
        if #available(macOS 12.0, *) {
            let (data, response) = try await urlSession.data(for: apiRequest.request)
            if response.isSuccess {
                return try JSONDecoder().decode(T.SuccessfulResponseDataType.self, from: data)
            } else {
                let apiError = try JSONDecoder().decode(T.ErrorResponseDataType.self, from: data)
                throw apiError
            }
        } else {
            typealias RequestContinuation = CheckedContinuation<T.SuccessfulResponseDataType, Error>
            return try await withCheckedThrowingContinuation({ (continuation: RequestContinuation) in
                cancellable = urlSession.dataTaskPublisher(for: self.apiRequest.request)
                    .tryMap { data, response -> Data in
                        if response.isSuccess {
                            return data
                        } else {
                            let apiError = try JSONDecoder().decode(T.ErrorResponseDataType.self, from: data)
                            throw apiError
                        }
                    }
                    .decode(type: T.SuccessfulResponseDataType.self, decoder: JSONDecoder())
                    .sink(receiveCompletion: { result in
                        switch result {
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        case .finished:
                            break
                        }
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    })
            })
        }
    }

    private var cancellable: AnyCancellable?
}

extension Optional where Wrapped: URLResponse {
    var isSuccess: Bool {
        if let statusCode = (self as? HTTPURLResponse)?.statusCode {
            return statusCode >= 200 && statusCode < 400
        }
        return false
    }
}

extension URLResponse {
    var isSuccess: Bool {
        if let statusCode = (self as? HTTPURLResponse)?.statusCode {
            return statusCode >= 200 && statusCode < 400
        }
        return false
    }
}
