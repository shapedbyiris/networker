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

extension APIRequest {
    public func perform(urlSession: URLSession = .shared) async throws -> SuccessfulResponseDataType {
        if #available(macOS 12.0, *) {
            let (data, response) = try await urlSession.data(for: request)
            if response.isSuccess {
                return try JSONDecoder().decode(SuccessfulResponseDataType.self, from: data)
            } else {
                let apiError = try JSONDecoder().decode(ErrorResponseDataType.self, from: data)
                throw apiError
            }
        } else {
            typealias RequestContinuation = CheckedContinuation<SuccessfulResponseDataType, Error>
            return try await withCheckedThrowingContinuation({ (continuation: RequestContinuation) in
                let _ = urlSession.dataTaskPublisher(for: self.request)
                    .tryMap { data, response -> Data in
                        if response.isSuccess {
                            return data
                        } else {
                            let apiError = try JSONDecoder().decode(ErrorResponseDataType.self, from: data)
                            throw apiError
                        }
                    }
                    .decode(type: SuccessfulResponseDataType.self, decoder: JSONDecoder())
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
