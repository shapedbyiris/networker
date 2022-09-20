//
//  Networker.swift
//  HTTPClient
//
//  Created by Ariel Elkin on 19/07/2019.
//  Copyright © 2019 IRIS. All rights reserved.
//

import Combine
import Foundation

public protocol APIRequest {
    var request: URLRequest { get }

    associatedtype SuccessfulResponseDataType: Decodable
    associatedtype ErrorResponseDataType: Error, Decodable
}

public extension APIRequest {
    func perform(urlSession: URLSession = .shared) async throws -> SuccessfulResponseDataType {
        if #available(macOS 12.0, iOS 15.0, watchOS 15.0, tvOS 15.0, macCatalyst 15.0, *) {
            let (data, response) = try await urlSession.data(for: request)
            if response.isSuccess {
                return try JSONDecoder().decode(SuccessfulResponseDataType.self, from: data)
            } else {
                let apiError = try JSONDecoder().decode(ErrorResponseDataType.self, from: data)
                throw apiError
            }
        } else {
            typealias RequestContinuation = CheckedContinuation<SuccessfulResponseDataType, Error>

            var cancelBag = Set<AnyCancellable>()

            return try await withCheckedThrowingContinuation { (continuation: RequestContinuation) in
                urlSession.dataTaskPublisher(for: self.request)
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
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        case .finished:
                            break
                        }
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    })
                    .store(in: &cancelBag)
            }
        }
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
